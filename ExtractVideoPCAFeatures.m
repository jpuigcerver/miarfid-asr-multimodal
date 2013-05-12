function ExtractVideoPCAFeatures(fname, H, W, m, C, d )
fid = fopen(fname);
figure;
while 1
    l = fgetl(fid);
    if ~ischar(l), break, end
    I = histeq(imresize(imread(l), [H, W]));
    I = double(I(:)') / 255.0;
    x = (I - m) * C(:,1:d);
    I2 = x * C(:,1:d)' + m;
    subplot(1,2,1), subimage(reshape(I, [H, W]));
    subplot(1,2,2), subimage(reshape(I2, [H, W]));
    [fpath, fname, ~] = fileparts(l);
    [~, dname, ~] = fileparts(fpath);
    us=char(dname(1:5));
    st=char(dname(7:end));
    [~,~,~]=mkdir(['data/features/pca/', us, '/', st]);
    fo = fopen(['data/features/pca/', us, '/', st, '/', fname(1:3), '.pca'], 'w');
    fprintf(fo, '%f\n', x);
    fclose(fo);
    pause
end
fclose(fid);

end

