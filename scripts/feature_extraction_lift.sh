# Call this script as `bash feature_extraction_lift.sh path/to/dataset` and
# change the path to the base directory of LIFT defined in $_LIFT_BASE_PATH.

DATASET_PATH=$(realpath $1)

export _LIFT_BASE_PATH="path/to/LIFT"

export OMP_NUM_THREADS=4
export THEANO_FLAGS="device=gpu,floatX=float32,base_compiledir=$DATASET_PATH/lift/compile"
export MKL_THREADING_LAYER=GNU

_LIFT_NUM_KEYPOINT=5000
_LIFT_SAVE_PNG=0
_LIFT_USE_THEANO=1

_LIFT_C_CODE_PATH="${_LIFT_BASE_PATH}/c-code"
_LIFT_PYTHON_CODE_PATH="${_LIFT_BASE_PATH}/python-code"

# Make sure libSIFT is compiled
if [ ! -f "${_LIFT_C_CODE_PATH}/libSIFT.so" ]
then
    (cd "${_LIFT_C_CODE_PATH}"; \
     cmake .. && make
    )
fi

mkdir -p $DATASET_PATH/lift
mkdir -p $DATASET_PATH/lift/compile

for image_name in $(ls $DATASET_PATH/images);
do
    # Test image and model settings
    _LIFT_TEST_IMG=$(realpath $DATASET_PATH/images/$image_name)
    _LIFT_TEST_IMG_NAME=$(basename $_LIFT_TEST_IMG)
    _LIFT_TEST_CONFIG="${_LIFT_BASE_PATH}/models/configs/picc-finetune-nopair.config"
    _LIFT_MODEL_DIR="${_LIFT_BASE_PATH}/models/picc-best/"

    # Output settings
    _LIFT_TEST_OUTPUT=$(realpath $DATASET_PATH)
    _LIFT_KP_FILE_NAME="${_LIFT_TEST_OUTPUT}/lift/${_LIFT_TEST_IMG_NAME}_kp.txt"
    _LIFT_ORI_FILE_NAME="${_LIFT_TEST_OUTPUT}/lift/${_LIFT_TEST_IMG_NAME}_ori.txt"
    _LIFT_DESC_FILE_NAME="${_LIFT_TEST_OUTPUT}/lift/${_LIFT_TEST_IMG_NAME}_desc.h5"

    if [[ -f $_LIFT_KP_FILE_NAME && -f $_LIFT_ORI_FILE_NAME && -f $_LIFT_DESC_FILE_NAME ]]; then
        continue;
    fi

    (cd $_LIFT_PYTHON_CODE_PATH; \
     python compute_detector.py \
        $_LIFT_TEST_CONFIG \
        $_LIFT_TEST_IMG \
        $_LIFT_KP_FILE_NAME \
        $_LIFT_SAVE_PNG \
        $_LIFT_USE_THEANO \
        0 \
        $_LIFT_MODEL_DIR \
        $_LIFT_NUM_KEYPOINT \
    )

    (cd $_LIFT_PYTHON_CODE_PATH; \
     python compute_orientation.py \
        $_LIFT_TEST_CONFIG \
        $_LIFT_TEST_IMG \
        $_LIFT_KP_FILE_NAME \
        $_LIFT_ORI_FILE_NAME \
        0 \
        0 \
        $_LIFT_MODEL_DIR
    )

    (cd $_LIFT_PYTHON_CODE_PATH; \
     python compute_descriptor.py \
        $_LIFT_TEST_CONFIG \
        $_LIFT_TEST_IMG \
        $_LIFT_ORI_FILE_NAME \
        $_LIFT_DESC_FILE_NAME \
        0 \
        0 \
        $_LIFT_MODEL_DIR
    )
done

rm -rf $DATASET_PATH/lift/compile
