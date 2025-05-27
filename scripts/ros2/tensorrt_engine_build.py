import numpy as np
import onnx
import os
import tensorrt as trt
import pycuda.driver as cuda
import pycuda.autoinit
import numpy
import argparse

def generate_calibration_data(input_shape, num_samples=100):
    """캘리브레이션용 더미 데이터 생성"""
    return np.random.random(size=(num_samples, *input_shape[1:])).astype(np.float32)


class Calibrator(trt.IInt8Calibrator):
    def __init__(self, calibration_data, batch_size, input_shape, cache_file):
        super().__init__()
        self.calibration_data = calibration_data
        self.batch_size = batch_size
        self.current_index = 0
        self.input_shape = input_shape
        self.cache_file = cache_file

        # 메모리 크기 계산을 int64로 확실히 처리
        size_in_bytes = int(self.batch_size * numpy.prod(input_shape) * numpy.dtype(numpy.float32).itemsize)

        # GPU 메모리 할당
        self.device_input = cuda.mem_alloc(size_in_bytes)

    def get_batch_size(self):
        return self.batch_size

    def get_batch(self, names):
        if self.current_index + self.batch_size > len(self.calibration_data):
            return None

        batch = self.calibration_data[self.current_index:self.current_index + self.batch_size]
        cuda.memcpy_htod(self.device_input, batch.astype(np.float32))
        self.current_index += self.batch_size
        return [self.device_input]

    def read_calibration_cache(self):
        if os.path.exists(self.cache_file):
            with open(self.cache_file, "rb") as f:
                return f.read()
        return None

    def write_calibration_cache(self, cache):
        with open(self.cache_file, "wb") as f:
            f.write(cache)

    def get_algorithm(self):
        return trt.CalibrationAlgoType.ENTROPY_CALIBRATION_2  # 또는 ENTROPY_CALIBRATION, LEGACY_CALIBRATION


def build_engine_fp16(onnx_path, engine_path, input_tensor_name, input_shape=(1, 3, 60, 60)):
    """FP16 TensorRT 엔진 생성"""
    if not os.path.exists(onnx_path):
        raise FileNotFoundError(f"❌ ONNX 파일이 존재하지 않습니다: {onnx_path}")

    TRT_LOGGER = trt.Logger(trt.Logger.VERBOSE)

    with trt.Builder(TRT_LOGGER) as builder, \
            builder.create_network(1 << int(trt.NetworkDefinitionCreationFlag.EXPLICIT_BATCH)) as network, \
            trt.OnnxParser(network, TRT_LOGGER) as parser:

        config = builder.create_builder_config()
        config.set_memory_pool_limit(trt.MemoryPoolType.WORKSPACE, 1 << 32)

        # FP16만 설정
        config.flags = 1 << int(trt.BuilderFlag.FP16)

        # 입력 텐서 설정
        print(f"입력 텐서 크기 설정: {input_shape}")
        profile = builder.create_optimization_profile()
        profile.set_shape(input_tensor_name, input_shape, input_shape, input_shape)
        config.add_optimization_profile(profile)

        # ONNX 파일 파싱 및 엔진 빌드
        with open(onnx_path, 'rb') as model:
            if not parser.parse(model.read()):
                print('ONNX 파일 파싱에 실패했습니다.')
                for error_index in range(parser.num_errors):
                    print(f"파서 에러 [{error_index}]: {parser.get_error(error_index)}")
                raise ValueError("ONNX 파일 파싱에 실패했습니다.")

        try:
            print('FP16 TensorRT 엔진 빌드 중...')
            serialized_engine = builder.build_serialized_network(network, config)
            if serialized_engine:
                print(f'FP16 엔진 빌드 성공! 저장 중: {engine_path}')
                with open(engine_path, 'wb') as f:
                    f.write(serialized_engine)
            else:
                print('FP16 엔진 빌드 실패!')
        except Exception as e:
            print(f'FP16 엔진 빌드 중 예외 발생: {e}')
            serialized_engine = None

        return serialized_engine



def build_engine_int8(onnx_path, engine_path, input_tensor_name, input_shape=(1, 3, 60, 60)):
    if not os.path.exists(onnx_path):
        raise FileNotFoundError(f"❌ ONNX 파일이 존재하지 않습니다: {onnx_path}")

    # Calibration 설정
    batch_size = 1
    cache_file = os.path.join(os.path.dirname(engine_path), "calibration.cache")
    calibration_data = generate_calibration_data(input_shape, num_samples=100)

    TRT_LOGGER = trt.Logger(trt.Logger.VERBOSE)

    with trt.Builder(TRT_LOGGER) as builder, \
            builder.create_network(1 << int(trt.NetworkDefinitionCreationFlag.EXPLICIT_BATCH)) as network, \
            trt.OnnxParser(network, TRT_LOGGER) as parser:

        config = builder.create_builder_config()
        config.set_memory_pool_limit(trt.MemoryPoolType.WORKSPACE, 1 << 32)

        # INT8 양자화 설정
        config.flags = (
                1 << int(trt.BuilderFlag.INT8) |
                1 << int(trt.BuilderFlag.FP16)
        )

        # Calibrator 설정
        calibrator = Calibrator(
            calibration_data=calibration_data,
            batch_size=batch_size,
            input_shape=input_shape,
            cache_file=cache_file
        )
        config.int8_calibrator = calibrator

        # 입력 텐서 설정
        print(f"입력 텐서 크기 설정: {input_shape}")
        profile = builder.create_optimization_profile()
        profile.set_shape(input_tensor_name, input_shape, input_shape, input_shape)
        config.add_optimization_profile(profile)

        # ONNX 파일 파싱
        print(f"ONNX 파일을 읽는 중... {onnx_path}")
        with open(onnx_path, 'rb') as model:
            if not parser.parse(model.read()):
                print('ONNX 파일 파싱에 실패했습니다.')
                for error_index in range(parser.num_errors):
                    print(f"파서 에러 [{error_index}]: {parser.get_error(error_index)}")
                raise ValueError("ONNX 파일 파싱에 실패했습니다.")

        # 엔진 빌드
        try:
            print('TensorRT 엔진 빌드 중...')
            serialized_engine = builder.build_serialized_network(network, config)
            if serialized_engine:
                print(f'엔진 빌드 성공! 엔진 파일을 저장합니다: {engine_path}')
                with open(engine_path, 'wb') as f:
                    f.write(serialized_engine)
            else:
                print('엔진 빌드 실패!')
        except Exception as e:
            print(f'엔진 빌드 중 예외 발생: {e}')
            serialized_engine = None

        return serialized_engine


def argument_parser():
    parser = argparse.ArgumentParser(description='TensorRT Engine Builder')
    parser.add_argument('--onnx_path', type=str, required=True, help='Path to the ONNX model file')
    parser.add_argument('--engine_path_fp16', type=str, required=True, help='Path to save the FP16 engine file')
    parser.add_argument('--engine_path_int8', type=str, required=True, help='Path to save the INT8 engine file')
    return parser.parse_args()

if __name__ == "__main__":


    # onnx_path = '~/Documents/A4VAI-SITL/ROS2/ros2_ws/src/pathplanning/pathplanning/model/weight.onnx'
    # engine_path_fp16 = onnx_path + "_fp16.trt"
    # engine_path_int8 = onnx_path + "_int8.trt"

    args = argument_parser()
    onnx_path = args.onnx_path
    engine_path_fp16 = args.engine_path_fp16
    engine_path_int8 = args.engine_path_int8

    input_tensor_name = "observation"
    input_shape = (1, 3, 60, 60)

    # ONNX 모델 체크
    try:
        model = onnx.load(onnx_path)
        onnx.checker.check_model(model)
        print("✅ ONNX 파일이 정상입니다.")
    except Exception as e:
        print(f"❌ ONNX 파일이 손상되었습니다: {e}")

    # FP16 엔진 생성
    print("\n🔄 FP16 엔진 생성 중...")
    engine_fp16 = build_engine_fp16(onnx_path, engine_path_fp16, input_tensor_name, input_shape)

    # INT8 엔진 생성
    print("\n🔄 INT8 엔진 생성 중...")
    engine_int8 = build_engine_int8(onnx_path, engine_path_int8, input_tensor_name, input_shape)
