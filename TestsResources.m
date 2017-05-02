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
        
        function [spten, spmat, normten, normmat] = initializeMulti2(m)
            spmat = sparse(m, m);
            normmat = zeros(m, m);

            for i = 1:m
                val = rand();
                spmat(i, i) = val;
                normmat(i, i) = val;
            end

            spten = SpTensor(m + 5, m + 5, m);
            normten = zeros(m + 5, m + 5,m);
            for i = 1:m
                val = rand();
                spten(i, i, i) = val;
                normten(i, i, i) = val;
                val = rand();
                spten(m + 2, m + 2, i) = val;
                normten(m + 2, m + 2, i) = val;
                val = rand();
                spten(m + 4, m + 4, i) = val;
                normten(m + 4, m + 4, i) = val;
            end
        end
    end
end