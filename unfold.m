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