m = 4;
mode = 1;

[spten, spmat, normten, normmat] = TestsResources.initializeMulti1(m, mode);

spres = TensorOperations.multi(spten, spmat, mode);
normres = multi(normten, normmat, mode);

for i = 1:m
    for j = 1:m
        for k = 1:m
            assert(normres(i, j, k) == spres(i, j, k));
        end
    end
end