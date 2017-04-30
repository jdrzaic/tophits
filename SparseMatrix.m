classdef SparseMatrix < handle
    % Sparse matrix format
    properties
        k
        l
        m
        mat
    end
    
    methods
        function obj = SparseMatrix(k, l, m)
            if k < 1 || l < 1 || m < 1
                error('n and m must be non-zero integers.');
            end
            obj.k = k;
            obj.l = l;
            obj.m = m;
            % generated data - needs indexing overloading
            obj.mat = cell(m, 1);
            obj.mat{1} = [2 5 5 2];
        end
        
        function addCoordinateForWord(obj, wordInd, i, j)
            if wordInd < 1 || wordInd > obj.m
                error('Third argument not valid.')
            end
            if i < 1 || i > obj.k
                error('First argument not valid.')
            end
            if j < 1 || j > obj.l
                error('Second argument not valid.')
            end
            currSize = length(obj.mat{wordInd});
            obj.mat{wordInd}(currSize + 1) = i;
            obj.mat{wordInd}(currSize + 2) = j;
        end
        
        function outargs = subsref(obj, S)
            msgID = 'MYFUN:BadIndex';
            err = 0;
            if length(S) ~= 1
                msg = 'Indexing invalid.';
                err = 1;
            end
            if strcmp(S(1).type, '{}')
                msg = 'Cell contents reference from a non-cell araray object.';
                err = 1;
            end
            if strcmp(S(1).type, '.')
                msg = 'Struct contents reference from a non-struct array object.';
                err = 1;
            end
            if err
                baseException = MException(msgID,msg);
                throw(baseException)
            end
            S.subs
            switch length(S.subs)
                case 1
                    outargs = obj.getElementByIndex(S.subs(1));
                case 2
                case 3
                otherwise
                    error('Not a valid indexing exception.');
            end
        end
        
        function obj = subsasgn(obj, S, varargin)
        
        end
        
        function indexelement = getElementByIndex(obj, indexCell)
            index = indexCell{1};  % unwrap index
            if index < 1 || index > obj.m * obj.k * obj.l
                error('Index not in valid range.')
            end
            % slice for the index
            prevSliceIndex = floor(index / (obj.k * obj.l));
            sliceIndex = ceil(index / (obj.k * obj.l));
            % index in the current slice
            indexInSlice = index - prevSliceIndex * (obj.k * obj.l);

            % number of (i,j) pairs in a slice
            sizeAnchor = size(obj.mat{sliceIndex}, 2) / 2;
            for i = 1:sizeAnchor
                if obj.mat{sliceIndex}(2 * i - 1) == 1 && obj.mat{sliceIndex}(2 + i + 1) == 1
                    indexelement = 1;
                    return
                end
            end
            indexelement = 0;
        end

    end 
end

