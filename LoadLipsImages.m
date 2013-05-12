function [F, C] = LoadLipsImages( fname, N, H, W )
F = zeros(N, H * W);
C = zeros(N, 1);
fid = fopen(fname);
%figure
for i=1:N
    l = fgetl(fid); %fscanf(fid, '%s %d');
    if ~ischar(l), break, end
    %fprintf(1, '%s\n', l);
    A = sscanf(l, '%s %d');
    c = A(end);
    l = char(A(1:end-1)');
    fprintf(1, '%d: %s\n', i, l);
    I = histeq(imresize(imread(l), [H, W]));
    %J = histeq(I);
    %subplot(1,2,1), subimage(I)
    %subplot(1,2,2), subimage(J)
    %pause
    F(i, :) = double(I(:)') / 255.0;
    C(i, :) = c;
end
fclose(fid);
Nout = max(C);
C2 = zeros(N, Nout);
for i=1:N
    j = C(i);
    C2(i,j)=1;
end
C = C2;
end

