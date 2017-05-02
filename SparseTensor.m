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
            % obj.mat{ind} = [i1 j1 v1 i2 j2 vj]
            obj.mat = cell(m, 1);
            obj.mat{1} = [1 1 1 1 2 2];
            obj.mat{2} = [2 2 2];
        end
        
        function outargs = subsref(obj, S)
            obj.handleError(S);
            switch length(S.subs)
                case 3
                    outargs = obj.getElementsBy3Indexes(S.subs{1}, S.subs{2}, S.subs{3});
                otherwise
                    error('Not a valid indexing exception.');
            end
        end
        
        function obj = subsasgn(obj, S, varargin)
            argin = varargin{1};
            handleError(obj, S)
            switch length(S.subs)
                case 3
                    obj.setElementsBy3Indexes(S.subs{1}, S.subs{2}, S.subs{3}, argin);
                otherwise
                    error('Not a valid indexing exception.');
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
                sizeSlice = size(slicePoints, 2) / 3;
                for i = 1:sizeSlice
                    foundRow = slicePoints(3 * i - 2);
                    foundCol = slicePoints(3 * i - 1);
                    [foundRowValidation, foundRowInd] = ismember(foundRow, rows);
                    [foundColValidation, foundColInd] = ismember(foundCol, cols);
                    if foundRowValidation && foundColValidation
                        indexelements(foundRowInd, foundColInd, slice - sliceOffset + 1) = 1;
                    end
                end
            end
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
                
        function setElementsBy3Indexes(obj, rows, cols, ancs, argin)
        end

        function extendMatIfNeeded(obj, sliceIndex)
            if sliceIndex > obj.m
                obj.m = sliceIndex;
            end
        end

    end  
end

