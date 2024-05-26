// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");

string token = "EwCYA8l6BAAUbDba3x2OMJElkF7gJ4z/VbCPEz0AAX04AAC1DjhaCAufsKSpryhUL5YNJczwYSeNuFtfdgVaorm8bn12/E8Xbo0uNo4jqrt/dKmV3iXKNl5zDFw+5Q5J5YI0AkTxafJOgI73E+HA5qBhG4PVYYCTfLMaNjE54VQPLbvHcD3rRzktPjKCZAuchsDHEpEeQzyEMVHp60swPBrkx1fxC2VECKxGwDqU3f/nFladjCuB70be3m3jmGJvS5SibP9UvRHLegAI5iDN7PbaKxmLLHXBkQzAM4wOxpK67qafA9mTD3Vz+enU1PT4Rdad34+dGCXwWD0FIJWsoAXW863utzepVweJll7QvlCHnflQoocAm8ZvgtU+eY8DZgAACEHh96J05a1HaAIrA/wBsKhaHXDwc/1cDZHsubvxQ8/otA/gnBVut/JbTd7D+RnqtvsxCz3OiBwoTPQLu+X+JlIx018ybWIt8/FXz+hkoN/LxyfeCaba/nngjmyyflEw1Wsk8ySUeCsJ24St7nLq1hJkP2mKvHoZRxr3nERzajg//e83KmNb1B/bnJSOHWWL7roRBnv+Sl5zHXEABDMt33eiHhDdYmTBkNNMOZxK0juVn2P9BtudM/ZN13t85mNbCimaZd/rK8CctIRnHmAnjB7ff7gOSF8+SCJyRwSkeLx1Cou2584qs56M9zzhZp/Dy6YWkTBqIxby3a09/MCJNlNmWCsxCbH2S9ps5LEb+NkYGX7FH0V1m/dgixZ7hZlMzs6c+m5XFtjPFiExJ2L4EZL2IBMIu9x4w2uHZPQrsCh+e+VkYwbV1YrLpuA5TaQQOrVPPts+YWewUDf5SAv5SeMUXOpoHFyfFzzh3sRfSBXfcswIFSFV9I5Y2cM+MEDxqGW+q8Ea3JtyMEZzUy+QVhmHepmROlNJvTj/IIA4LVXMl41uU/t27+lKMbLHVDdgid3iF/x0TuGXL32VhPlw3atuzcPJLGDha4tO9ZsuMg+aKHiReEALpxptEqI3iQfqPkkqdgOWd0cU8pmUl4bIlPbAtomzbMSueYl2wKfgEJs4mkXo0/7zOErDwhpr2LIdmOYFIdH66DVWbLapKKlFBC/wcM4jeakuSVnbm+4TqROUNZR+9jJRgmBKqYH+pw45yiMjkwpEMuXW98l1rVWvGLGBIBQmH3149XHarnD/f32BO/6lUXGZ/iQSlswkD0ZbE6NUpgI=";
using (var client = new HttpClient())
{

    client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
    using (var content = new MultipartFormDataContent("MyPartBoundary198374"))
    {
        var stringContent = new StringContent("<h1>Hello</h1>", System.Text.Encoding.UTF8, "text/html");
        var inkml = new StringContent(@"
            <inkml:ink xmlns:emma=""http://www.w3.org/2003/04/emma"" xmlns:msink=""http://schemas.microsoft.com/ink/2010/main"" xmlns:inkml=""http://www.w3.org/2003/InkML"">
            <inkml:definitions>
            <inkml:context xml:id=""ctxCoordinatesWithPressure"">
            <inkml:inkSource xml:id=""inkSrcCoordinatesWithPressure"">
                <inkml:traceFormat>
                <inkml:channel name=""X"" type=""integer"" max=""32767"" units=""himetric""/>
                <inkml:channel name=""Y"" type=""integer"" max=""32767"" units=""himetric""/>
                <inkml:channel name=""F"" type=""integer"" max=""32767"" units=""dev""/>
                </inkml:traceFormat>
                <inkml:channelProperties>
                <inkml:channelProperty channel=""X"" name=""resolution"" value=""1"" units=""1/himetric""/>
                <inkml:channelProperty channel=""Y"" name=""resolution"" value=""1"" units=""1/himetric""/>
                <inkml:channelProperty channel=""F"" name=""resolution"" value=""1"" units=""1/dev""/>
                </inkml:channelProperties>
            </inkml:inkSource>
            </inkml:context>
            <inkml:brush xml:id=""br0"">
            <inkml:brushProperty name=""width"" value=""100"" units=""himetric""/>
            <inkml:brushProperty name=""height"" value=""100"" units=""himetric""/>
            <inkml:brushProperty name=""color"" value=""#0000FF""/>
            <inkml:brushProperty name=""transparency"" value=""0""/>
            <inkml:brushProperty name=""tip"" value=""ellipse""/>
            <inkml:brushProperty name=""rasterOp"" value=""copyPen""/>
            <inkml:brushProperty name=""ignorePressure"" value=""false""/>
            <inkml:brushProperty name=""antiAliased"" value=""true""/>
            <inkml:brushProperty name=""fitToCurve"" value=""false""/>
            </inkml:brush>
            </inkml:definitions>
            <inkml:traceGroup>
            <inkml:trace xml:id=""st0"" contextRef=""#ctxCoordinatesWithPressure"" brushRef=""#br0"">1423 7569 3456, 1468 7288 7040, 1506 7176 7168, 1599 7006 7168, 1744 6768 7168, 1952 6474 7168, 2228 6128 7168, 2583 5737 7168, 3001 5313 7168, 3483 4854 6784, 4007 4413 6400, 4548 3999 6144, 5059 3657 6016, 5530 3402 5888, 5921 3244 5888, 6213 3196 5632, 6421 3253 5504, 6532 3413 5760, 6545 3700 6016, 6427 4130 6400, 6170 4678 6912, 5797 5314 7936, 5331 6012 9088, 4792 6748 9728, 4225 7506 10496, 3709 8257 11008, 3239 8965 11520, 2890 9600 11648, 2671 10148 11776, 2574 10600 11648, 2605 10958 11520, 2725 11259 11648, 2972 11481 11776, 3347 11603 11904, 3876 11632 12160, 4544 11569 12032, 5317 11410 12032, 6174 11202 11776, 7083 10983 11520, 7974 10779 10752, 8811 10628 10112, 9566 10531 8960, 10191 10497 7936, 10706 10542 7424, 11084 10644 7040, 11333 10804 6912, 11469 11040 6912, 11484 11367 6784, 11385 11817 6656, 11152 12374 6528, 10795 13023 6400, 10376 13722 5888, 9906 14458 5504, 9460 15181 5376, 9096 15845 5376, 8854 16410 3584, 8741 16914 1920, 8757 17335 1024, 8893 17699 256</inkml:trace>
            <inkml:trace xml:id=""st1"" contextRef=""#ctxCoordinatesWithPressure"" brushRef=""#br0"">12105 14014 2560, 11649 14071 3840, 11047 14166 5120, 10839 14195 4992, 10549 14222 5504, 10237 14227 6144, 9909 14199 7040, 9622 14125 7936, 9375 13991 8704, 9181 13790 9472, 9045 13516 9856, 8977 13152 10368, 8986 12709 10368, 9088 12189 10368, 9250 11614 10240, 9475 11031 10240, 9742 10459 10112, 10020 9923 10112, 10277 9438 9984, 10492 9022 9856, 10655 8667 9856, 10748 8376 9856, 10777 8140 9856, 10751 7959 9856, 10656 7819 9856, 10504 7726 9984, 10285 7668 10112, 10018 7668 10240, 9680 7720 10240, 9293 7824 10240, 8898 7982 10240, 8491 8177 10368, 8115 8387 10112, 7794 8584 9984, 7547 8740 9472, 7387 8839 8960, 7334 8875 7808, 7362 8846 6784, 7504 8715 3456, 7800 8473 256</inkml:trace>
            <inkml:trace xml:id=""st2"" contextRef=""#ctxCoordinatesWithPressure"" brushRef=""#br0"">9674 7756 5632, 9350 7776 8448, 8993 7925 11904, 8909 7989 12544, 8787 8104 12928, 8647 8263 13440, 8502 8455 13440, 8370 8681 13568, 8250 8925 13440, 8149 9190 13312, 8070 9448 12928, 8017 9690 12672, 7988 9900 12416, 7988 10076 12160, 8022 10210 12032, 8090 10293 11904, 8212 10327 12032, 8382 10298 12288, 8624 10205 12160, 8914 10040 12160, 9253 9807 12032, 9612 9542 11904, 9975 9258 11648, 10302 8977 11520, 10569 8740 11520, 10782 8557 11648, 10931 8434 12160, 11008 8362 12672, 11033 8339 13184, 11015 8371 13696, 10950 8455 13696, 10834 8599 13696, 10692 8789 13952, 10533 9031 14208, 10373 9309 14336, 10214 9613 14464, 10083 9929 14336, 9992 10239 14336, 9952 10526 14208, 9977 10773 14208, 10052 10981 14080, 10194 11146 13952, 10384 11253 13824, 10651 11307 13696, 10974 11304 13056, 11354 11248 12544, 11766 11153 12160, 12176 11040 11776, 12560 10918 11520, 12884 10813 11264, 13133 10744 11136, 13316 10705 11136, 13433 10714 10752, 13492 10755 10368, 13495 10841 9600, 13454 10954 8960, 13390 11103 7296, 13307 11264 5760, 13230 11429 3712, 13158 11580 1792, 13094 11734 1024, 13037 11867 256</inkml:trace>
            <inkml:trace xml:id=""st3"" contextRef=""#ctxCoordinatesWithPressure"" brushRef=""#br0"">8190 7100 3328, 7857 7096 4992, 7592 7062 6144, 7556 7037 5760, 7531 6978 6784, 7533 6881 7808, 7592 6736 7808, 7701 6539 7936, 7886 6295 7808, 8133 6017 7808, 8452 5707 8192, 8794 5397 8576, 9153 5110 8832, 9468 4877 9088, 9719 4698 9344, 9895 4583 9600, 9995 4524 10112, 10015 4524 10624, 9957 4592 10752, 9816 4732 11008, 9599 4947 11520, 9350 5209 12032, 9099 5490 13056, 8864 5777 14208, 8685 6033 14592, 8581 6252 14976, 8569 6422 14464, 8624 6551 13952, 8767 6636 12672, 8977 6677 11520, 9255 6682 10880, 9572 6659 10368, 9904 6620 10240, 10233 6577 10240, 10544 6539 10496, 10811 6514 10752, 11035 6505 11392, 11217 6528 12032, 11357 6582 12288, 11450 6670 12672, 11502 6801 12544, 11513 6969 12416, 11474 7193 12160, 11382 7455 12032, 11246 7765 11776, 11083 8106 11520, 10898 8459 11264, 10734 8803 11136, 10606 9115 11008, 10540 9368 11008, 10533 9554 10368, 10588 9687 9856, 10708 9764 8064, 10898 9778 6272, 11146 9744 3968, 11454 9658 1664, 11775 9554 896, 12094 9420 128</inkml:trace>
            <inkml:trace xml:id=""st4"" contextRef=""#ctxCoordinatesWithPressure"" brushRef=""#br0"">8739 9547 1152, 8622 9531 1664, 8642 9497 1280, 8664 9463 128</inkml:trace>
            <inkml:trace xml:id=""st5"" contextRef=""#ctxCoordinatesWithPressure"" brushRef=""#br0"">11701 13399 4480, 11644 13267 6656, 11766 12951 9216, 11852 12836 9344, 11990 12652 9600, 12212 12408 9856, 12485 12128 9984, 12795 11847 10240, 13117 11585 10368, 13413 11370 10496, 13676 11205 10624, 13890 11098 10752, 14044 11040 11008, 14151 11031 11392, 14209 11071 11392, 14225 11160 11520, 14196 11297 11520, 14128 11476 11520, 14031 11702 11648, 13908 11958 11904, 13762 12245 12544, 13617 12544 13312, 13486 12826 13312, 13386 13073 13440, 13327 13283 13440, 13307 13446 13440, 13330 13562 13312, 13400 13645 13312, 13510 13684 12928, 13648 13686 12672, 13827 13670 12416, 14017 13638 12160, 14200 13598 12160, 14359 13573 12160, 14485 13564 12160, 14578 13582 12160, 14632 13638 12288, 14646 13734 12416, 14615 13874 12416, 14544 14048 12544, 14438 14256 12288, 14311 14486 12160, 14182 14728 12160, 14058 14970 12160, 13958 15179 12032, 13884 15362 12032, 13847 15506 11392, 13845 15617 10752, 13875 15688 9984, 13942 15719 9344, 14044 15712 8320, 14171 15660 7424, 14316 15567 6272, 14465 15441 5120, 14617 15292 2688, 14753 15120 384, 14854 14937 256, 14917 14762 256</inkml:trace>
            </inkml:traceGroup>
            </inkml:ink>",
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
