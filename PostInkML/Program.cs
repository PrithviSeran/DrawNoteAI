using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
/*
using (var client = new HttpClient())
{
    string token = "EwCYA8l6BAAUbDba3x2OMJElkF7gJ4z/VbCPEz0AATo88AnQfludYcHqteQsHZO82XMxgaayspCv/BnNSCa8Pj7L6/EozMPdMVBg9ycL1s4U8VvScLSJ1ehJrbuY/EmqTaLIwu/uhyuDfEfrNOqqFKfMIHnYicGUDaqv92KtGsx29UwMrdubAzgIJgGHfgavg3C7KRU8f/m86LKb8ZdHdcd4LeaYKSBzJ1ztKwqCNRByUkLsSRRXWDtP75+a08A37z55KxpFS3JCvt2jT5m4C01zEpd2HqcDCgOtNXdupDKfEXpUQe/V7QGifOAE6ZTbWkxyeadwprckkOUv+0TXBhmMdjGkvvQdxYekzUnCxWzaXRv9r0Rxg/R7BTHvWJ4DZgAACGYTRB5BvuNdaAIuYo5YXE+XPJt7VrdcIDmTLcwJPJYCHiQhk4NExls3MqGFOt5OB8aqpz6cnPX39I52NMs4HsN2j0rhfMD2cBe/QvF1spKOv1cwRYXcwxW226jRQYqWG2GNZ5Srr/5j/DoCdqlitCowDn5zPrdBnD9MzOtJJnxXEybBKJk1FHuDZZcWYQYn/cQHbSFFgVuvRKFgrY/hR33RskyEdYTJCbO5jVEklAlgdcfdr30Twi8u1pkCgQy/O6ZGSs2PKsnAVxtXBOQS4ouwzptbGDl9dh8CdG92o69TiF/6adhPQF3cFiQ1SaVrF0MCicwxAJOanJ4AQJkRW/C8cpj2PnobAEBxjCxYgsLkj1Wc8D+A6Zh5xjXFQINuUWIQhr774oFyr6sfqYsC0LGqpmMiwEd5f2oEPcmCXHSTOGroLUdBgRjexoGmykLkZgnnCNOcpn9PvL5RHIdwWdz3WGbMA+4rW6JQ3XGweK8JJ2aEA22D3roPfcRcX9/2Zcj09s8V+lvjeywXZ4nH0OmJRvlvUz5Y3sdSJXaRbdv4UFSEEyg9fQbBVyWlmTQ/HEe7GfMeD0MJ5IKXpbhPi1zlMSibxASNwtYLvhmnK9VeqIFhIwN/wy8DRVmWk2OLapWC/FdzK97sra8HVpmBBdeLM+7oOwCmcDpr2qedbqtVQZ2Y/cEjA8b7i12EnZBTVLPzlgrAFCZ5hnCJIkWHjNp++VOFD6bTB6uLQWrZy2IznNUBAI+/d9Dt6Czavxa5aMo8Di/N3wJaSgMqlrgcbSTHip4sT+l0hwI5me8V8+BhCWo3BBE55bV1gnlt/HQKJNcWpgI=";

    client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
    using (var content = new MultipartFormDataContent("MyPartBoundary198374"))
    {
        var stringContent = new StringContent("<h1>Hello</h1>", System.Text.Encoding.UTF8, "text/html");
        var inkml = new StringContent(File.ReadAllText(@"inkML.txt"),
            System.Text.Encoding.UTF8,
            "application/inkml+xml");

        
        content.Add(stringContent, "presentation");
        //-onenote-inkml");
        content.Add(inkml, "presentation-onenote-inkml");


        using (
           var message =
               await client.PostAsync("https://graph.microsoft.com/v1.0/me/onenote/sections/0-A213A7A8D7193228!82019/pages", content))
        {
            Console.WriteLine(message);
        }
    }
}
*/

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureServices(services => {
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();
    })
    .Build();

host.Run();

