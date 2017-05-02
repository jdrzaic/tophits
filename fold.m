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
