classdef PARAFAC 
    methods(Static)
        function [u, v, w, sigma] = calculate(A, p, epsilon)
            n = TensorOperations.size(A, 1);
            m = TensorOperations.size(A, 3);
            u = zeros(p, n);
            v = zeros(p, n);
            w = zeros(p, m);
            sigma = zeros(p);
            lambdaNew = 0;
            lambdaOld = 0;
            for k = 1:p
                x = ones(1, n);
                y = ones(1, n);
                z = ones(1, m);
                counter = 1;
                while counter < 3 || abs(lambdaOld - lambdaNew) < epsilon
                    x = TensorOperations.multi(TensorOperations.multi(A, y, 2), z, 3) - PARAFAC.subtractSum(sigma, u, v, w, y, z);
                    y = TensorOperations.multi(TensorOperations.multi(A, x, 1), z, 3) - PARAFAC.subtractSum(sigma, v, u, w, x, z); 
                    z = TensorOperations.multi(TensorOperations.multi(A, x, 1), y, 2) - PARAFAC.subtractSum(sigma, w, u, v, x, y);
                    lambdaOld = lambdaNew;
                    xNorm = norm(x);
                    yNorm = norm(y);
                    zNorm = norm(z);
                    lambdaNew = xNorm * yNorm * zNorm;
                    x = x / xNorm;
                    y = y / yNorm;
                    z = z / zNorm;
                end
                u(k, :) = x;
                v(k, :) = y;
                w(k, :) = z;
                sigma(k) = lamdbaNew;
            end
        end
        
        function subsum = subtractSum(sigmas, us, vs, ws, y, z)
            iter = length(sigmas); % previous iteration
            for i = 1:iter
                stepsubsum = sigmas(i) * us(i, :) * (y' * vs(i, :)) * (z' * ws(i, :));
                if i == 1
                    subsum = stepsubsum;
                else
                    subsum = subsum + stepsubsum;
                end
            end
        end
    end
end
