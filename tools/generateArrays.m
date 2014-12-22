clear all; clc;
format shortEng;


available = [194.961 174.653 149.702 130.99 209.583 116.435];
available = available*1e6;
available = [ available available/1e2 available/1e4];
available = sort(available,'descend')
available = available
freq = [];

for i=10:99
    freq = [ i*1e6 freq ];
end;

for i=10:99
    freq = [ i*1e5 freq ];
end;

for i=10:99
    freq = [ i*1e4 freq ];
end;

for i=10:99
    freq = [ 1000*i freq ];
end;

for i=10:99
    freq = [ 100*i freq ];
end;

for i=10:99
    freq = [ 10*i freq ];
end;

for i=10:99
    freq = [ i*1e0 freq ];
end;

for i=10:99
    freq = [ i*1e-1 freq ];
end;

freq = sort(freq);
freq = unique(freq);
%req

divisors = []
errs = []
res = []


% output values
divisors = []
sources = []

numbExp = zeros(10);
numbExpGen = zeros(10);

maxDiv = 0;
for i=1:length(freq)
    freq(i);
    f = freq(i);
    divs = round(available/f);
    err = abs(f - available./divs);
    err = 100.0*err/f; %err in %
    [val ind] = min(err);
    errs(i) = val;
    divisors(i) = divs(ind);
    sources(i) = ind;
    
    
    exppDisplay = floor(log10(freq(i)));
    numbExp(exppDisplay+1) = numbExp(exppDisplay+1) + 1;
    
    
    
    genFreq = available(sources(i))/divisors(i);
    expp = floor(log10(genFreq));
    tmp.freqGenerating = genFreq/10^expp;
    tmp.expGenerating = expp;
    
    numbExpGen(expp+1) = numbExpGen(expp+1) + 1;
    
    tmp.freqDisplay = freq(i)/10^exppDisplay;
    tmp.expDisplay = exppDisplay;
    
    tmp.source = ind;
    tmp.div = divs(ind);
    
    maxDiv = max(maxDiv, tmp.div);
    tmp;
    res = [ res tmp ];
    
    
    freqsDisplay(exppDisplay+1, numbExp(exppDisplay+1)+1) = tmp.freqDisplay;
    freqsGenerating(expp+1, numbExp(expp+1)+1) = tmp.freqGenerating;
end;

outFreqs = available(sources)./divisors
figure(1);
plot(freq, outFreqs,'o-b')
figure(2);
[maxerr indice] = max(errs) % max error
semilogx(freq, errs,'or')


%%%%%%%%% GENERATING ARRAY FILES %%%%%%%%%%%%%%

fileSources = fopen('sources.txt','w')
fileDividers = fopen('dividers.txt','w')
fileFrequncyActual = fopen('freqActual.txt','w')

fprintf(fileSources,'type LUT_Sources_t is array(10 to %d) of integer;\n',length(res)+9)
fprintf(fileDividers,'type LUT_Dividers_t is array(10 to %d) of integer;\n',length(res)+9)
fprintf(fileFrequncyActual,'type LUT_Frequency_t is array(10 to %d) of string;\n',length(res)+9)

fprintf(fileSources,'signal LUT_Sources : LUT_Sources_t := (')
fprintf(fileDividers,'signal LUT_Dividers : LUT_Dividers_t := (')
fprintf(fileFrequncyActual,'signal LUT_Frequency : LUT_Frequency_t := (')

for i=1:length(res)-1
        fprintf(fileSources,'%d, ',res(i).source);
        fprintf(fileDividers,'%d, ',res(i).div);
        fprintf(fileFrequncyActual, '"%s", ', [num2str(round(10*res(i).freqGenerating)) 'E' num2str(round(res(i).expGenerating))])
end
i=length(res);
fprintf(fileSources,'%d);\n',res(i).source);
fprintf(fileDividers,'%d);\n',res(i).div);
fprintf(fileFrequncyActual, '"%s")\n', [num2str(round(10*res(i).freqGenerating)) 'E' num2str(round(res(i).expGenerating))])
    
fclose(fileSources);
fclose(fileDividers);
maxDiv