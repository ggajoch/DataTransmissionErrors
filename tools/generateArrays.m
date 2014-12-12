clear all; clc;
format shortEng;


available = [500e6, 495e3, 490e3, 485e6, 480e3, 475e3, 470e6, 465e3, 460e6, 455e6, 450e6, 440e6, 430e6, 425e6, 410e6, 400e6, 350e6, 300e6, 265e6];
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

fprintf(fileSources,'type LUT_Sources_%d_t is array(10 to %d) of integer;\n',0,numbExp(1))
fprintf(fileDividers,'type LUT_Dividers_%d_t is array(10 to %d) of integer;\n',0,numbExp(1))
fprintf(fileFrequncyActual,'type LUT_Frequency_%d_t is array(10 to %d) of string;\n',0,numbExp(1))

fprintf(fileSources,'signal LUT_Sources_%d : LUT_Sources_%d_t := (',0,0)
fprintf(fileDividers,'signal LUT_Dividers_%d : LUT_Dividers_%d_t := (',0,0)
fprintf(fileFrequncyActual,'signal LUT_Frequency_%d : LUT_Frequency_%d_t := (',0,0)

for i=1:length(res)
    if( i > 1 )
        if res(i).expDisplay ~= res(i-1).expDisplay
            fprintf(fileSources,'type LUT_Sources_%d_t is array(10 to %d) of integer;\n',res(i).expDisplay,numbExp(res(i).expDisplay+1))
            fprintf(fileDividers,'type LUT_Dividers_%d_t is array(10 to %d) of integer;\n',res(i).expDisplay,numbExp(res(i).expDisplay+1))
            fprintf(fileFrequncyActual,'type LUT_Frequency_%d_t is array(10 to %d) of string;\n',res(i).expDisplay,numbExp(res(i).expDisplay+1))

            fprintf(fileSources,'signal LUT_Sources_%d : LUT_Sources_%d_t := (',res(i).expDisplay,res(i).expDisplay)
            fprintf(fileDividers,'signal LUT_Dividers_%d : LUT_Dividers_%d_t := (',res(i).expDisplay,res(i).expDisplay)
            fprintf(fileFrequncyActual,'signal LUT_Frequency_%d : LUT_Frequency_%d_t := (',res(i).expDisplay,res(i).expDisplay)
        end
        if i == length(res) || res(i).expDisplay ~= res(i+1).expDisplay %last element in table
            fprintf(fileSources,'%d);\n',res(i).source);
            fprintf(fileDividers,'%d);\n',res(i).div);
            
            
            fprintf(fileFrequncyActual, '"%s")\n', [num2str(round(10*res(i).freqGenerating)) 'E' num2str(round(res(i).expGenerating))])
        else
            fprintf(fileSources,'%d, ',res(i).source);
            fprintf(fileDividers,'%d, ',res(i).div);
            fprintf(fileFrequncyActual, '"%s", ', [num2str(round(10*res(i).freqGenerating)) 'E' num2str(round(res(i).expGenerating))])
        end
    end
end

fclose(fileSources);
fclose(fileDividers);
maxDiv