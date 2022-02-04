function [Synx,Freq,ROCOF] = NoFit ( ...
	SignalParams, ...
	DelayCorr, ...
	MagCorr, ...
	F0, ...
	AnalysisCycles, ...
	SampleRate, ...
	Samples ...
)
[~,nPhases] = size(Samples);
Synx = zeros(nPhases+1,1);
Freq = 0;
ROCOF = 0;

end