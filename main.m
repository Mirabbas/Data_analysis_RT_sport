function main()
 
  WordFileName='lalalala.doc'; 
   CurDir=pwd;
   FileSpec = fullfile(CurDir,WordFileName);
   [ActXWord,WordHandle]=StartWord(FileSpec); 
   
figure;
hold on
plot(res_l);
plot(result,'r');
hold off
title('�����');
xlabel('���');ylabel('���');
FigureIntoWord(ActXWord); 
    
CloseWord(ActXWord,WordHandle,FileSpec);
end