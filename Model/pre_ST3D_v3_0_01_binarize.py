
#============================================================================
# Preprocessing Model for ST3D indexing - V 3.0
#
# Kenny Davila
# - Created:  March 10, 2021
# - Modified: December 30, 2021
#
#============================================================================

import torch

from console_ui_process import ConsoleUIProcess

from FCN_lecturenet import FCN_LectureNet
from FCN_lecturenet_binarizer import FCN_LectureNet_Binarizer, FCN_LectureNet_Image_Binarizer

def get_worker_video(process):

    # use FCN LectureNet
    print("... loading model ...")

    output_dir = process.configuration.get_str("OUTPUT_PATH")
    #print(output_dir, "\n")

    model_dir = output_dir + "/" + process.configuration.get_str("BINARIZATION_FCN_LECTURENET_DIR")
    #print(model_dir, "\n")

    model_filename = model_dir + "/" + process.configuration.get_str("BINARIZATION_FCN_LECTURENET_FILENAME")
    #print(model_filename, "\n")

    use_cuda = False
    #process.configuration.get("FCN_BINARIZER_USE_CUDA", False)
    #print("HERE1?\n\n\n\n\n")


    lecture_net = FCN_LectureNet.CreateFromConfig(process.configuration, 3, False)
    #print("HERE2?\n\n\n\n\n")

    lecture_net.load_state_dict(torch.load(model_filename, map_location=torch.device('cpu')))
    #print("HERE3?\n\n\n\n\n")

    lecture_net.eval()

    # use cuda ...
    if use_cuda:
        print("HERE4?\n\n\n\n\n")
        lecture_net = lecture_net.cuda()

    worker_binarizer = FCN_LectureNet_Binarizer(lecture_net)

    debug_mode = process.configuration.get("BINARIZATION_DEBUG_MODE", False)
    debug_end_time = process.configuration.get_int("BINARIZATION_DEBUG_END_TIME", 50000)

    worker_binarizer.set_debug_mode(debug_mode, 0, debug_end_time, process.img_dir, process.current_lecture.title)
    print("BINARY: ", worker_binarizer.frame_times,"\n")
    print("BINARY: ", worker_binarizer.frame_indices,"\n")
    print("BINARY: ", worker_binarizer.compressed_frames,"\n")

    return worker_binarizer


def get_worker_image(process):

    # use FCN LectureNet
    print("... loading model ...")

    """
    output_dir = process.configuration.get_str("OUTPUT_PATH")
    #print(output_dir, "\n")

    model_dir = output_dir + "/" + process.configuration.get_str("BINARIZATION_FCN_LECTURENET_DIR")
    #print(model_dir, "\n")

    model_filename = model_dir + "/" + process.configuration.get_str("BINARIZATION_FCN_LECTURENET_FILENAME")
    #print(model_filename, "\n")

    use_cuda = False
    #process.configuration.get("FCN_BINARIZER_USE_CUDA", False)
    #print("HERE1?\n\n\n\n\n")

    """
    use_cuda = False
    lecture_net = FCN_LectureNet.CreateFromConfig(3, False)
    #print("HERE2?\n\n\n\n\n")

    #add name here instead
    lecture_net.load_state_dict(torch.load("LectureNet_model_BIN_V34_final_test.dat", map_location=torch.device('cpu')))
    #print("HERE3?\n\n\n\n\n")

    lecture_net.eval()

    # use cuda ...
    if use_cuda:
        print("HERE4?\n\n\n\n\n")
        lecture_net = lecture_net.cuda()

    worker_binarizer = FCN_LectureNet_Image_Binarizer(lecture_net)

    """
    debug_mode = process.configuration.get("BINARIZATION_DEBUG_MODE", False)
    debug_end_time = process.configuration.get_int("BINARIZATION_DEBUG_END_TIME", 50000)

    worker_binarizer.set_debug_mode(debug_mode, 0, debug_end_time, process.img_dir, process.current_lecture.title)
    print("BINARY: ", worker_binarizer.frame_times,"\n")
    print("BINARY: ", worker_binarizer.frame_indices,"\n")
    print("BINARY: ", worker_binarizer.compressed_frames,"\n")
    """

    return worker_binarizer



def get_results(worker):
    # using Lecture net ... delete ...
    del worker.lecture_net
    # now, empty CUDA cache ...
    torch.cuda.empty_cache()

    return (worker.frame_times, worker.frame_indices, worker.compressed_frames)

def use_as_module(path_to_config_file):

    return ConsoleUIProcess() #.FromConfigPath(path_to_config_file, "", None, "BINARIZATION_OUTPUT")


def main():
    # usage check
    #if not ConsoleUIProcess.usage_with_config_check(sys.argv):
    #    return

    #process = ConsoleUIProcess.FromConfigPath(sys.argv[1], sys.argv[2:], None, "BINARIZATION_OUTPUT")

    process = ConsoleUIProcess()
    #use_as_module("ACCESS2021_release/configs/FCN_LectureNet.conf")

    #if not process.initialize():
    #    return

    #fps = process.configuration.get_float("SAMPLING_FPS", 1.0)


    #process.start_video_processing(fps, get_worker_video, get_results, 0, True, True)

    process.start_image_processing(get_worker_image)

    #print(process.database)

    print("finished")


if __name__ == "__main__":
    main()

