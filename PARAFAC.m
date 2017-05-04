classdef PARAFAC 
    methods(Static)
        function [u, v, w, sigma] = calculate(A, p, epsilon)
            n = TensorOperations.size(A, 1);
            m = TensorOperations.size(A, 3);
            u = sparse(n, p);
            v = sparse(n, p);
            w = sparse(m, p);
            sigma = sparse(1, p);
            lambdaNew = 0;
            lambdaOld = 0;
            for k = 1:p
                x = sparse(1:n, ones(n, 1), ones(n, 1), n, 1);
                y = sparse(1:n, ones(n, 1), ones(n, 1), n, 1);
                z = sparse(1:m, ones(m, 1), ones(m, 1), m, 1);
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
