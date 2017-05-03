classdef PARAFAC 
    methods(Static)
        function [u, v, w, sigma] = calculate(A, p, epsilon)
            n = TensorOperations.size(A, 1);
            m = TensorOperations.size(A, 3);
            u = zeros(n, p);
            v = zeros(n, p);
            w = zeros(m, p);
            sigma = zeros(1, p);
            lambdaNew = 0;
            lambdaOld = 0;
            for k = 1:p
                x = ones(n, 1);
                y = ones(n, 1);
                z = ones(m, 1);
                counter = 1;
                while counter < 3 || abs(lambdaOld - lambdaNew) >= epsilon
                    baseX = TensorOperations.multi(TensorOperations.multi(A, y', 2), z', 3); % multiply tensor x matrix
                    baseX = baseX(:, 1, 1); % squeze baseX by dimension 2 and 3
                    x = baseX - PARAFAC.subtractSum(sigma, u, v, w, y, z, k - 1);
                    baseY = TensorOperations.multi(TensorOperations.multi(A, x', 1), z', 3);
                    baseY = baseY(1, :, 1);
                    y = baseY - PARAFAC.subtractSum(sigma, v, u, w, x, z, k - 1); 
                    baseZ = TensorOperations.multi(TensorOperations.multi(A, x', 1), y', 2);
                    baseZ = baseZ(1, 1, :)';
                    z = baseZ - PARAFAC.subtractSum(sigma, w, u, v, x, y, k - 1);
                    lambdaOld = lambdaNew;
                    xNorm = norm(x);
                    yNorm = norm(y);
                    zNorm = norm(z);
                    lambdaNew = xNorm * yNorm * zNorm;
                    x = x / xNorm;
                    y = y / yNorm;
                    z = z / zNorm;
                    counter = counter + 1;
                end
                u(:, k) = x;
                v(:, k) = y;
                w(:, k) = z;
                sigma(k) = lambdaNew;
            end
        end
        
        function subsum = subtractSum(sigmas, us, vs, ws, y, z, iter)
            subsum = 0;
            for i = 1:iter
                stepsubsum = sigmas(i) * us(:, i) * (y' * vs(:, i)) * (z' * ws(:, i));
                if i == 1
                    subsum = stepsubsum;
                else
                    subsum = subsum + stepsubsum;
                end
            end
        end
    end
end
