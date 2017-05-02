classdef TestsResources
    methods(Static)
        function [spten, spmat, normten, normmat] = initializeMulti1(m)
            spmat = sparse(m, m);
            normmat = zeros(m, m);

            for i = 1:m
                val = rand();
                spmat(i, i) = val;
                normmat(i, i) = val;
            end

            spten = SpTensor(m, m, m);
            normten = zeros(m, m,m);
            for i = 1:m
                val = rand();
                spten(i, i, i) = val;
                normten(i, i, i) = val;
            end
        end
    end
end