classdef SparseTensor < handle
    % Sparse 3-dimensional tensor format
    properties
        k
        l
        m
        mat
    end
    
    methods
        function obj = SparseTensor(k, l, m)
            if k < 1 || l < 1 || m < 1
                error('n and m must be non-zero integers.');
            end
            obj.k = k;
            obj.l = l;
            obj.m = m;
            % generated data - needs indexing overloading
            obj.mat = cell(m, 1);
            obj.mat{1} = [1 1 1 2];
            obj.mat{2} = [2 2];
        end
        
        function outargs = subsref(obj, S)
            obj.handleError(S);
            switch length(S.subs)
                case 1
                    outargs = obj.getElementsByIndex(S.subs);
                case 2
                    outargs = obj.getElementsBy2Indexes(S.subs{1}, S.subs{2});
                case 3
                    outargs = obj.getElementsBy3Indexes(S.subs{1}, S.subs{2}, S.subs{3});
                otherwise
                    error('Not a valid indexing exception.');
            end
        end
        
        function obj = subsasgn(obj, S, varargin)
            argin = varargin{1};
            handleError(obj, S)
            % values stored can only be 1 and 0 - maybe treat everything
            % except 0 as 1?
            if any(ceil(argin) ~= floor(argin)) || any(argin < 0) || any(argin > 1)
                error('Only 1 and 0 values allowed.')
            end
            switch length(S.subs)
                case 1
                    obj.setElementsByIndex(S.subs{1});
                case 2
                    obj.setElementsBy2Indexes(S.subs{1}, S.subs{2});
                case 3
                    obj.setElementsBy3Indexes(S.subs{1}, S.subs{2}, S.subs{3});
                otherwise
                    error('Not a valid indexing exception.');
            end
        end
        
        function indexelements = getElementsBy2Indexes(obj, rows, cols)
            if rows == ':'
                rows = 1:obj.k;
            end
            if cols == ':'
                cols = 1:(obj.l * obj.m);
            end
            if any(cols > obj.m * obj.l) || any(rows > obj.k)
                error('Not a valid indexing exception.');
            end
            % matrix to store elements
            indexelements = zeros(length(rows), length(cols));
            % iterating over slices
            for slice = 1:obj.m
                for elemInd = 1:size(obj.mat{slice}, 2) / 2
                    % transform index to the ones required when unwrapping
                    % tensor
                    foundCol = (slice - 1) * obj.l + obj.mat{slice}(elemInd * 2);
                    foundRow = obj.mat{slice}(elemInd * 2 - 1);
                    [foundRowValidation, foundRowInd] = ismember(foundRow, rows);
                    [foundColValidation, foundColInd] = ismember(foundCol, cols);
                    if foundRowValidation && foundColValidation 
                        indexelements(foundRowInd, foundColInd) = 1;
                    end
                end
            end
        end
        
        function indexelements = getElementsBy3Indexes(obj, rows, cols, ancs)
            if rows == ':'
                rows = 1:obj.k;
            end
            if cols == ':'
                cols = 1:obj.l;
            end
            if ancs == ':'
                ancs = 1:obj.m;
            end
            indexelements = zeros(length(rows), length(cols), length(ancs));
            % index in the fetched tensor
            sliceOffset = ancs(1); % offset for slices
            for slice = ancs
                slicePoints = obj.mat{slice};
                sizeSlice = size(slicePoints, 2) / 2;
                for row = rows
                    for col = cols
                        for i = 1:sizeSlice
                            foundRow = slicePoints(2 * i - 1);
                            foundCol = slicePoints(2 * i);
                            [foundRowValidation, foundRowInd] = ismember(foundRow, rows);
                            [foundColValidation, foundColInd] = ismember(foundCol, cols);
                            if foundRowValidation && foundColValidation
                                indexelements(foundRowInd, foundColInd, slice - sliceOffset + 1) = 1;
                            end
                        end
                    end
                end
            end
        end
        
        function indexelements = getElementsByIndex(obj, indexCell)
            indexes = indexCell{1};  % unwrap index
            if indexes == ':'
                indexes = 1:(obj.k * obj.l * obj.m);
            end
            
            indexelements = zeros(length(indexes), 1);
            for indexId = 1:length(indexes)
                indexelements(indexId) = obj.getElementForIndex(indexes(indexId));
            end
        end
        
        function indexelement = getElementForIndex(obj, index)
            
            if index < 1 || index > obj.m * obj.k * obj.l
                error('Index not in valid range.');
            end
            % slice for the index
            prevSliceIndex = floor(index / (obj.k * obj.l));
            sliceIndex = ceil(index / (obj.k * obj.l));
            % index in the current slice
            indexInSlice = index - prevSliceIndex * (obj.k * obj.l);
            % row in current slice
            row = mod(indexInSlice, obj.k);
            if row == 0
                row = obj.k;
            end
            % column in current slice
            col = ceil(indexInSlice / obj.k);
            if col == 0
                col = obj.l;
            end

            % number of (i,j) pairs in a slice
            sizeAnchor = size(obj.mat{sliceIndex}, 2) / 2;
            for i = 1:sizeAnchor
                if obj.mat{sliceIndex}(2 * i - 1) == row && obj.mat{sliceIndex}(2 * i) == col
                    indexelement = 1;
                    return
                end
            end
            indexelement = 0;
        end
        
        function handleError(~, S)
            msgID = 'subsref:BadIndex';
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
        end
        
        function setElementsByIndex(obj, indexes)
            if indexes == ':'
                indexes = 1:(obj.k * obj.l * obj.m);
            end
            for indexId = 1:length(indexes)
                obj.setElementForIndex(indexes(indexId));
            end
        end

        function setElementsBy2Indexes(obj, rows, cols)
        end
        
        function setElementsBy3Indexes(obj, rows, cols, ancs)
        end
        
        function setElementForIndex(obj, index)
            if index < 1
                error('Index not in valid range.');
            end
            % slice for the index
            prevSliceIndex = floor(index / (obj.k * obj.l));
            sliceIndex = ceil(index / (obj.k * obj.l));
            obj.extendMatIfNeeded(sliceIndex);
            % index in the current slice
            indexInSlice = index - prevSliceIndex * (obj.k * obj.l);
            % row in current slice
            row = mod(indexInSlice, obj.k);
            if row == 0
                row = obj.k;
            end
            % column in current slice
            col = ceil(indexInSlice / obj.k);
            if col == 0
                col = obj.l;
            end
            currSliceLen = length(obj.mat{sliceIndex});
            obj.mat{sliceIndex}(currSliceLen + 1) = row;
            obj.mat{sliceIndex}(currSliceLen + 2) = col;
        end

        function extendMatIfNeeded(obj, sliceIndex)
            if sliceIndex > obj.m
                obj.m = sliceIndex;
            end
        end

    end  
end
