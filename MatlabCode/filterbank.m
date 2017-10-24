function H = filterbank(sig, m,Z,g,c,b)
% m : delayline array
% Z : matrix with the four delayed signals
% g : gain coefficient for FDN
% c : output gain coefficients
% b : input gain coefficients
% d : direct signal gain coefficient

% H = c*D(z)/(I-D(z)*A*c)
% D(z) : diag(Z);
% c : output gain coefficient from FDN
% I : eye(length(Z))
% A : feedback matrix


gain = g/sqrt(2);
a = gain.*[0 1 1 0; -1 0 0 -1; 1 0 0 -1; 0 1 1 0]; % Feedback matrix

%A = [a -a -a -a; -a a -a -a; -a -a a -a; -a -a -a a];

sig = sig';

% Delaylines
z1 = Z(1,:);
z2 = Z(2,:);
z3 = Z(3,:);
z4 = Z(4,:);


for n = 1:length(sig)

    tmp = [z1(m(1)) z2(m(2)) z3(m(3)) z4(m(4))];

    fdn(n)= sig(n) + cn(1)*z1(m(1)) + cn(2)*z2(m(2)) ...
          + cn(3)*z3(m(3)) + cn(4)*z4(m(4));

    z1 = [(sig(n)*bn(1) + tmp*a(1,:)') z1(1:length(z1)-1)];
    z2 = [(sig(n)*bn(2) + tmp*a(2,:)') z2(1:length(z2)-1)];
    z3 = [(sig(n)*bn(3) + tmp*a(3,:)') z3(1:length(z3)-1)];
    z4 = [(sig(n)*bn(4) + tmp*a(4,:)') z4(1:length(z4)-1)];
end



end
