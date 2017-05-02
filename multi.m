function[A] = multi(T, M, mode)
     dim = TensorOperations.size(T, 0);
     A = fold(M * unfold(T,mode), dim(setdiff(1:length(dim), mode)), mode);
end