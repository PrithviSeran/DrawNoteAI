import azure.functions as func
import logging
from pre_ST3D_v3_0_01_binarize import main
#from testing.FCN_lecturenet import FCN_LectureNet
#from FCN_lecturenet_binarizer import FCN_LectureNet_Image_Binarizer #, FCN_LectureNet


app = func.FunctionApp()

@app.blob_trigger(arg_name="myblob", path="rundnnmodel/{name}.jpg",
                               connection="rundnnmodel_STORAGE") 
def blob_trigger(myblob: func.InputStream):
    logging.info(f"Python blob trigger function processed blob"
                f"Name: {myblob.name}"
                f"Blob Size: {myblob.length} bytes")
    main()
    

