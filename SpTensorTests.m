m = 4;
mode = 3;

[spten, spmat, normten, normmat] = TestsResources.initializeMulti1(m);

spres = TensorOperations.multi(spten, spmat, mode);
normres = multi(normten, normmat, mode);

for i = 1:m
    for j = 1:m
        for k = 1:m
            assert(normres(i, j, k) == spres(i, j, k));
        end
    end
end

[spten, spmat, normten, normmat] = TestsResources.initializeMulti2(m);

spres = TensorOperations.multi(spten, spmat, mode);
normres = multi(normten, normmat, mode);

mode = 3;

for i = 1:m + 5
    for j = 1:m + 5
        for k = 1:m
            assert(normres(i, j, k) == spres(i, j, k));
        end
    end
end