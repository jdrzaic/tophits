function[A]=multi(T,M,mode)
    dim=size(T);
    A=fold(M*unfold(T,mode),dim(setdiff(1:length(dim),mode)),mode);
end
        
    