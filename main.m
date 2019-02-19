function main()
 
  WordFileName='test_1.doc'; 
   CurDir=pwd;
   FileSpec = fullfile(CurDir,WordFileName);
   [ActXWord,WordHandle]=StartWord(FileSpec); 
   
figure;
hold on
plot(res_l);
plot(result,'r');
hold off
title('Надув');
xlabel('сек');ylabel('код');
FigureIntoWord(ActXWord); 
    
CloseWord(ActXWord,WordHandle,FileSpec);
end
