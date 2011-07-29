clc, clear all ;

%Vout = 2.85 ;   % required output
Vout = 1.8 ;   % required output
%Vout = 3.6 ;

R1 = 240 ;      % (see. LM117.pdf)
Vref = 1.25 ;   % (see LM117.pdf, mc33269-d.pdf)
Iadj = 100e-6 ; % (see LM117.pdf, mc33269-d.pdf)
%Iadj = 0 ;

R2 = (Vout - Vref)/(Vref/R1+Iadj) ;

% check part
%R_2 = round(R2/100)*100 ;
R_values = [100,110,120,130,150,160,180,200,220,240,270,300,330,360,...
            390,430,470,510,560,620,680,750,820,910,1000,1100,1200,...
            1300,1500,1600,1800,2000,2200,2400,2700,3000] ;

%find nearest
fprintf('Vout = %2.1fv\n',Vout) ;
fprintf('Find nearest value:\n') ;
[R_2_err,tmp] = min(abs(R2-R_values)) ;
R_2 = R_values(tmp) ;
V_out = Vref*(1+R_2/R1)+Iadj*R_2 ;

fprintf('R1 = %5.1f Om\nR2 = %5.1f\nR2 ~ %5.1f Om\nOutput is %5.4f v\n', ...
    R1, R2, R_2, V_out) ;

%find nearest pair
fprintf('\nFind nearest pair values:\n') ;
err = 1e10 ;
min_n = -1 ;
min_k = -1 ;
for n=1:numel(R_values)
    for k=n:numel(R_values)
        R_2 = 1/(1/R_values(n)+1/R_values(k)) ;
        if abs(R_2-R2)<err
            min_n = n ;
            min_k = k ;
            err = abs(R_2-R2) ;
        end
    end
end
R_2 = 1/(1/R_values(min_n)+1/R_values(min_k)) ;
V_out = Vref*(1+R_2/R1)+Iadj*R_2 ;
fprintf('R1 = %5.1f Om\nR2 = %5.1f\n  R2_1 = %5.1f\n  R2_2 = %5.1f\nR2 ~ %5.1f Om\nOutput is %5.4f v\n', ...
    R1, R2, R_values(min_n),R_values(min_k), R_2, V_out) ;