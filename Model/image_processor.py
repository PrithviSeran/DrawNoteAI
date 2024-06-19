import cv2
from PIL import Image
from numpy import asarray
import numpy as np
from azure.storage.blob import ContainerClient
from azure.storage.blob import BlobClient 
from io import BytesIO
import copy




class ImageProcessor:
    
    def __init__(self):
        self.forced_width = None
        self.forced_height = None
        self.inkML = """<?xml version="1.0" encoding="utf-8"?>
<inkml:ink xmlns:emma="http://www.w3.org/2003/04/emma" xmlns:msink="http://schemas.microsoft.com/ink/2010/main" xmlns:inkml="http://www.w3.org/2003/InkML">
<inkml:definitions>
<inkml:context xml:id="ctxCoordinatesWithPressure">
<inkml:inkSource xml:id="inkSrcCoordinatesWithPressure">
    <inkml:traceFormat>
    <inkml:channel name="X" type="integer" max="32767" units="himetric"/>
    <inkml:channel name="Y" type="integer" max="32767" units="himetric"/>
    <inkml:channel name="F" type="integer" max="32767" units="dev"/>
    </inkml:traceFormat>
    <inkml:channelProperties>
    <inkml:channelProperty channel="X" name="resolution" value="1" units="1/himetric"/>
    <inkml:channelProperty channel="Y" name="resolution" value="1" units="1/himetric"/>
    <inkml:channelProperty channel="F" name="resolution" value="1" units="1/dev"/>
    </inkml:channelProperties>
</inkml:inkSource>
</inkml:context>
<inkml:brush xml:id="br0">
<inkml:brushProperty name="width" value="100" units="himetric"/>
<inkml:brushProperty name="height" value="100" units="himetric"/>
<inkml:brushProperty name="color" value="#0000FF"/>
<inkml:brushProperty name="transparency" value="0"/>
<inkml:brushProperty name="tip" value="ellipse"/>
<inkml:brushProperty name="rasterOp" value="copyPen"/>
<inkml:brushProperty name="ignorePressure" value="false"/>
<inkml:brushProperty name="antiAliased" value="true"/>
<inkml:brushProperty name="fitToCurve" value="false"/>
</inkml:brush>
</inkml:definitions>
<inkml:traceGroup>\n"""


    def force_resolution(self, width, height):
        self.forced_width = width
        self.forced_height = height

    
    def calculate_center(self, coordinates):
        sum_lat = 0
        sum_lng = 0

        for pair in coordinates:
            sum_lat += pair[0]
            sum_lng += pair[1]

        center_lat = sum_lat / len(coordinates)
        center_lng = sum_lng / len(coordinates)

        return [center_lat, center_lng]


    def transform_coordinates(self, coordinates, center, multiplier):
        transformed_coordinates = []

        for pair in coordinates:
            latitude = pair[0] - center[0]
            longitude = pair[1] - center[1]

            transformed_latitude = latitude * multiplier
            transformed_longitude = longitude * multiplier

            transformed_latitude += center[0]
            transformed_longitude += center[1]

            transformed_coordinates.append([int(transformed_latitude), int(transformed_longitude)])

        return np.array(transformed_coordinates)


    def binary_image_to_inkml(self, binary_image):
        # Load the binary image



        #image = Image.open(binary_image).convert('L')  # Convert to grayscale
        image = binary_image
        #np.array(Image.open('/Users/prithviseran/Documents/AI_Note_Writing/get-inkML/handwriting_image.png').convert('L'))

        print("In INKML Func: \n")
        print(image)
        print(image.shape)
        print("\n")


        # Detect black pixels (handwriting)
        handwriting_pixels = np.argwhere(image == 0) + 10000

        multiplier = 10

        # Calculate the center of the coordinates
        center = self.calculate_center(handwriting_pixels)

        # Subtract the center from each pair and multiply by the multiplier
        new = self.transform_coordinates(handwriting_pixels, center, multiplier)

        print(handwriting_pixels.shape)

        if handwriting_pixels.size == 0:
            print("No handwriting detected in the image.")
            return

        # Group adjacent pixels into strokes (simplified approach)
        strokes = []
        current_stroke = []
        temp = []

        #ink = ""
        stroke1 = '<inkml:trace xml:id="st'
        stroke2 = '" contextRef="#ctxCoordinatesWithPressure" brushRef="#br0">'
        total_strock = '<inkml:trace xml:id="st0" contextRef="#ctxCoordinatesWithPressure" brushRef="#br0">'

    

        def is_adjacent(p1, p2):

            check = np.abs(p1[0] - p2[0]) <= 1 and np.abs(p1[1] - p2[1]) <= 1

            return check

        count = 0
        for i in range(len(handwriting_pixels)):

            temp = copy.deepcopy(new[i])

            #temp[0] = temp[0] + 10*i
            #temp[1] = temp[1] + 10*i


            if i == 0 or is_adjacent(handwriting_pixels[i], handwriting_pixels[i - 1]):

                total_strock = total_strock + f'{temp[1]} {temp[0]} 30, '
                

            else:
                
                total_strock = total_strock.rstrip(', ')
                total_strock = total_strock + '</inkml:trace>\n'

                self.inkML = self.inkML + total_strock

                total_strock = stroke1 + str(count) + stroke2

                count = count + 1
                #strokes.append(current_stroke)

        self.inkML = self.inkML + "</inkml:traceGroup>\n</inkml:ink>"

        """
        file = open("demo.txt", "w")
        file.write(ink)
        file.close()
        """

    """
    if current_stroke:
        strokes.append(current_stroke)

    # Create InkML
    ink = ET.Element("ink")
    #trace_format = ET.SubElement(ink, '""traceFormat""')
    #channel_x = ET.SubElement(trace_format, '""channel""', name='""X""', type='""decimal""')
    #channel_y = ET.SubElement(trace_format, '""channel""', name='""Y""', type='""decimal""')

    for i, stroke in enumerate(strokes):

        #print(f"{p[1]} {p[0]} 3000, " for p in stroke)
        #inkml:trace xml:id="st0" contextRef="#ctxCoordinatesWithPressure" brushRef="#br0"
        trace = ET.SubElement(ink, '""inkml:trace""', id="st"+str(i), contextRef='\"\"#ctxCoordinatesWithPressure""', brushRef='""#br0""')
        
        trace_text = " ".join(f"{p[1]} {p[0]} 30," for p in stroke)
        trace.text = trace_text.rstrip(', ')


    # Write InkML to file
    tree = ET.ElementTree(ink)
    tree.write(inkml_output_path, encoding='utf-8', xml_declaration=True)
    """

    def increase_distance(self, coordinates, increment):
        new_coordinates = []
        for i in range(len(coordinates)):
            x, y = coordinates[i]
            if i == 0:
                new_coordinates.append((x, y))
            else:
                prev_x, prev_y = new_coordinates[-1]
                dx = x - prev_x
                dy = y - prev_y
                distance = np.sqrt(dx**2 + dy**2)
                scale_factor = (distance + increment) / distance
                new_x = prev_x + dx * scale_factor
                new_y = prev_y + dy * scale_factor
                new_coordinates.append((new_x, new_y))
        return np.array(new_coordinates)


    def doProcessing(self, image_worker):
        #initially....

        account_name = 'rundnnmodel'
        blob_name = 'user_image.jpg'
        account_key = '4u32CdrzDHidw0xorD44RQenXIir+W2U0OjDB9UyybiA8XUVuv9iAlR6E3TIwFYC5gpy5ytJUJbe+AStKCV02g=='
        connection_string = "DefaultEndpointsProtocol=https;AccountName=princenotes2;AccountKey=WyXAD4Ie8/JPhIe8igMqUwoM9/m+pmgnPZA36ZSicdt8xVjlJoIc4Zaq3Ti+jaWId7po/SxdFloi+AStnYkH4g==;EndpointSuffix=core.windows.net"
        block_blob_service = ContainerClient.from_connection_string(conn_str=connection_string, container_name = account_name)
        
        #BlockBlobService(account_name, account_key)
        blob_client = block_blob_service.get_blob_client(blob_name)
        blob_data = blob_client.download_blob().readall()
    
        #container_name = 'rundnnmodel'
        #blob = block_blob_service.get_blob_to_bytes(container_name, blob_name)

        image_data = BytesIO(blob_data)

        frame = np.array(Image.open(image_data).convert('L'))

        print(" Opened from BLOB: \n")
        print(frame)
        print(frame.shape)
        print("\n")

        

        #x = np.fromstring(blob.content, dtype='uint8')

        #frame = asarray(x)
        """
        frame = np.array(Image.open('/Users/prithviseran/Documents/AI_Note_Writing/get-inkML/handwriting_image.png'))


        print(" Opened from local dir: \n")
        print(frame)
        print(frame.shape)
        print("\n")
        """

        #if offset_frame > 0:

        #print("HERE????????")

        #frame_time = absolute_time + current_time
        #frame_idx = int(absolute_frame + current_frame)
        binary_image = image_worker.handleImage(frame)

        print(binary_image)

        self.binary_image_to_inkml(binary_image)

        print("HERE!!!!!!")

        #print(self.inkML)

        blob = BlobClient.from_connection_string(conn_str = connection_string,
                                             container_name="rundnnmodel", blob_name="inkML.xml")

        #data = "test"
        blob.upload_blob(self.inkML)

        #print("NOT HERE!!!!!!")

            
        #at the end of the processing of current video
        #capture.set(cv2.CAP_PROP_POS_AVI_RATIO, 1.0)
        #video_length = capture.get(cv2.CAP_PROP_POS_MSEC)
        #video_frames = capture.get(cv2.CAP_PROP_POS_FRAMES)

        #if video_length < current_time or video_frames < current_frame:
        #    video_frames = current_frame
        #    video_length = current_time
        
        #absolute_time += video_length
        #absolute_frame += video_frames

