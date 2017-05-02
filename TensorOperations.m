classdef TensorOperations < handle
    
    properties
    end
    
    methods(Static)
        function size = size(t, num)
            switch(num)
                case 1
                    size = t.k;
                case 2
                    size = t.l;
                case 3
                    size = t.m;
                case 0
                    size = [t.k, t.l, t.m];
                otherwise
                    error('Index out of range.')
            end
        end
        
        function[A]=fold(B,dekomp,mode)
            dim=size(B);
            %provjera valjaju li dimenzije
            if floor(dim(2)/dekomp(2))~=ceil(dim(2)/dekomp(2))
                disp('bad dimensions');
                return
            end
            if floor(dim(2)/dekomp(1))~=ceil(dim(2)/dekomp(1))
                disp('bad dimensions');
                return
            end

            if mode==1
                l=dim(1);
                m=dim(2)/dekomp(2);
                n=dim(2)/dekomp(1);
                A=SpTensor(l,m,n);
                for j=1:m
                    B(:,(n*(j-1)+1):(n*j))
                    A(:,j,:)=B(:,(n*(j-1)+1):(n*j));
                end
            elseif mode==2
                l=dim(2)/dekomp(2);
                m=dim(1);
                n=dim(2)/dekomp(1);
                A=SpTensor(l,m,n);
                for k=1:n
                   A(:,:,k)=B(:,(l*(k-1)+1):(k*l))';

                end
            elseif mode==3
                l=dim(2)/dekomp(2);
                m=dim(2)/dekomp(1);
                n=dim(1);
                A=SpTensor(l,m,n);
                for i=1:l
                    A(i,:,:)=B(:,(m*(i-1)+1):(i*m))';
                end
            end
        end
        
        function[B]=unfold(A,mode)
            if mode==1
                B=sparse(TensorOperations.size(A, 1),TensorOperations.size(A, 2)*TensorOperations.size(A, 3));
                for j=1:TensorOperations.size(A, 2)
                    B(:,(TensorOperations.size(A, 3)*(j-1)+1):(TensorOperations.size(A, 3)*j))=A(:,j,:);
                end
            elseif mode==2
                B=sparse(TensorOperations.size(A, 2),TensorOperations.size(A, 1)*TensorOperations.size(A, 3));
                for j=1:TensorOperations.size(A, 3)
                    B(:,(TensorOperations.size(A, 1)*(j-1)+1):(TensorOperations.size(A, 1)*j))=A(:,:,j)';
                end
            elseif mode==3
                B=sparse(TensorOperations.size(A, 3),TensorOperations.size(A, 1)*TensorOperations.size(A, 2));
                for j=1:TensorOperations.size(A, 1)
                    B(:,(TensorOperations.size(A, 2)*(j-1)+1):(TensorOperations.size(A, 2)*j))=A(j,:,:)';
                end
            end
        end
        
        function[A] = multi(T, M, mode)
             dim = TensorOperations.size(T, 0);
             A = TensorOperations.fold(M * TensorOperations.unfold(T,mode), dim(setdiff(1:length(dim), mode)), mode);
        end
    end
end