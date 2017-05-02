function[B]=unfold(A,mode)

dim=size(A);
if mode==1
    B=zeros(dim(1),dim(2)*dim(3));
    for j=1:dim(2)
        B(:,(dim(3)*(j-1)+1):(dim(3)*j))=squeeze(A(:,j,:));
    end
elseif mode==2
    B=zeros(dim(2),dim(1)*dim(3));
    for j=1:dim(3)
        B(:,(dim(1)*(j-1)+1):(dim(1)*j))=squeeze(A(:,:,j))';
    end
elseif mode==3
    B=zeros(dim(3),dim(1)*dim(2));
    for j=1:dim(1)
        B(:,(dim(2)*(j-1)+1):(dim(2)*j))=squeeze(A(j,:,:))';
    end
end
    
end