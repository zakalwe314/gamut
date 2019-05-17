close all, clear all
K=[98:100 1024];
FIG=0;
for k=1:length(K)
  [MDC(k),POINTS(k)]=tess2_Yscan(K(k),FIG);
  disp(['Luminance: ' num2str(POINTS(k)) ', Volume: ' num2str(MDC(k))])
end
semilogx(POINTS,MDC/MDC(end)*100,'.--')
xlabel('Grid points'), ylabel('Volume (%)'),xlim([1 1e5])
set(gca,'xtick',10.^[1:5],'ytick',90:100)