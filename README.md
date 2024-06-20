# DrawNote AI

DrawNote AI is an iOS app that scans whiteboard/chalkboard writings and drawings, transferring them to the user's OneNote account seamlessly. 

## Features

- **User Authentication**: Log in using your Outlook email with MSAL authentication.
- **Image Capture**: Take a picture of the board to capture writings and drawings.
- **Azure Integration**: Uploads images to Azure Storage and triggers a Python function for processing.
- **AI-Powered Recognition**: Uses a PyTorch pretrained model to extract and convert board content to InkML.
- **OneNote Sync**: Creates a new OneNote page with the extracted content in the user's specified section.

## Technology Stack

- **iOS App**: Developed in Swift.
- **Authentication**: MSAL (Microsoft Authentication Library).
- **Cloud Storage**: Azure Storage Container.
- **Machine Learning**: PyTorch pretrained model from [LectureMath](https://github.com/kdavila/lecturemath).
- **Markup Language**: InkML.
- **Serverless Functions**: Azure Functions (Python and C#).

## Workflow

1. **User Authentication**:
   - Users log into the app using their Outlook email via MSAL authentication.

2. **Image Capture**:
   - Users take a picture of the board within the app.

3. **Image Upload**:
   - The image is uploaded to an Azure Storage container.

4. **Python Processing**:
   - Upload triggers a Python function that processes the image with a PyTorch model.
   - Extracted writings and drawings are converted into InkML.

5. **InkML Upload**:
   - The generated InkML is uploaded to an Azure container, triggering another function.

6. **C# Processing**:
   - This function reads the InkML content and creates a new OneNote page in the user's specified section with the InkML content.

## Setup and Installation

### Prerequisites

- Xcode and Swift installed on your macOS.
- Azure account for storage and function deployment.
- OneNote account for syncing notes.
- MSAL library for authentication.

### Installation Steps

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/drawnote-ai.git
    cd drawnote-ai
    ```

2. **Install dependencies**:
    ```bash
    pod install
    ```

3. **Configure Azure and OneNote**:
    - Set up your Azure Storage container and functions.
    - Update the configuration files with your Azure and OneNote details.

4. **Build and Run**:
    - Open the project in Xcode.
    - Build and run the app on your iOS device or simulator.

## Usage

1. Log in using your Outlook email.
2. Capture the board writings and drawings.
3. The app processes and uploads the content.
4. Check your OneNote account for the new page with the captured content.


## Acknowledgements

- [LectureMath](https://github.com/kdavila/lecturemath) for the pretrained model.
- Microsoft for the MSAL library and OneNote integration.

---

*Happy Note Taking with DrawNote AI!*
