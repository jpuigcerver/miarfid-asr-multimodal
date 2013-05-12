function [N, H, W ] = GetMeanImageSize( fname )
H = 0; W = 0; N = 0;
fid = fopen(fname);
while 1
    l = fgetl(fid);
    if ~ischar(l), break, end
    %fprintf(1, '%s\n', l);
    I = imread(l);
    [h, w] = size(I);
    H = H + h;
    W = W + w;
    N = N + 1;
    %imshow(I);
    %pause
end
fclose(fid);

if N > 0
    H = H / N;
    W = W / N;
end

end

