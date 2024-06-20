using System.IO;
using System.Threading.Tasks;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;


namespace Prince.InkML
{
    public class RecieveInkML
    {
        private readonly ILogger<RecieveInkML> _logger;

        public RecieveInkML(ILogger<RecieveInkML> logger)
        {
            _logger = logger;
        }

        [Function(nameof(RecieveInkML))]
        public async Task Run([BlobTrigger("YOUR INKML ADDRESS", Connection = "THE CONNECTION STRING FROM local.settings.json")] Stream stream, string name)
        {
            using var blobStreamReader = new StreamReader(stream);
            var content = await blobStreamReader.ReadToEndAsync();

            var client = new HttpClient();
            _logger.LogInformation($"C# Blob trigger function Processed blob\n Name: {name} \n");

            string connectionString = @"DefaultEndpointsProtocol=https;AccountName=princenotes2;AccountKey=WyXAD4Ie8/JPhIe8igMqUwoM9/m+pmgnPZA36ZSicdt8xVjlJoIc4Zaq3Ti+jaWId7po/SxdFloi+AStnYkH4g==;EndpointSuffix=core.windows.net";
            //$"DefaultEndpointsProtocol=https;AccountName={storageAccountName};AccountKey={storageAccountKey};EndpointSuffix=core.windows.net";

            // Create a BlobServiceClient
            BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);

            // Get a reference to the container
            string containerName = "rundnnmodel";
            BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(containerName);

            // Get a reference to the blob
            string blobName = "authtoken.txt";
            BlobClient blobClient = containerClient.GetBlobClient(blobName);

            string UserImage = "user_image.jpg";
            BlobClient blobClientUserImage = containerClient.GetBlobClient(UserImage);

            string inkML_data = "inkML.xml";
            BlobClient blobClientInkML = containerClient.GetBlobClient(inkML_data);

            string pageName = "pageName.txt";
            BlobClient pageNameBlob = containerClient.GetBlobClient(pageName);

            string sectionId = "sectionId.txt";
            BlobClient sectionIdBlob = containerClient.GetBlobClient(sectionId);


            // Download the blob's contents and print it
            BlobDownloadInfo download = await blobClient.DownloadAsync();

            string contents = "";

            using (StreamReader reader = new StreamReader(download.Content, true))
            {
                contents = await reader.ReadToEndAsync();
                Console.WriteLine(contents);
            }

            BlobDownloadInfo downloadPage = await pageNameBlob.DownloadAsync();

            string contentsPageName = "";

            using (StreamReader reader = new StreamReader(downloadPage.Content, true))
            {
                contentsPageName = await reader.ReadToEndAsync();
                Console.WriteLine(contentsPageName);
            }

            BlobDownloadInfo downloadSection = await sectionIdBlob.DownloadAsync();

            string contentsSection = "";

            using (StreamReader reader = new StreamReader(downloadSection.Content, true))
            {
                contentsSection = await reader.ReadToEndAsync();
                Console.WriteLine(contentsSection);
            }

            
            string token = contents;

            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
            var content2 = new MultipartFormDataContent("MyPartBoundary198374");
            var stringContent = new StringContent($"<h1>{contentsPageName}</h1>", System.Text.Encoding.UTF8, "text/html");
            var inkml = new StringContent(content,
                System.Text.Encoding.UTF8,
                "application/inkml+xml");

            
            content2.Add(stringContent, "presentation");
            //-onenote-inkml");
            content2.Add(inkml, "presentation-onenote-inkml");


            using (
            var message =
                await client.PostAsync($"https://graph.microsoft.com/v1.0/me/onenote/sections/{contentsSection}/pages", content2))
            {
                Console.WriteLine(message);
            }

            //static async Task DeleteBlobAsync(BlobClient blobClientUserImage)
            //{
            await blobClientUserImage.DeleteAsync();
            await blobClientInkML.DeleteAsync();
            //}
            
        }

    
    }
    
}


