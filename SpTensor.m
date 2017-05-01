classdef SpTensor < handle
    properties
        k % number of rows
        l % number of cols
        m % number of slices
        mat % data
    end
    
    methods
        function obj = SpTensor(varargin)
            if length(varargin) < 3
                error('At least 3 arguments must be provided.')
            end
            obj.mat = cell(varargin{3}, 1);
            if length(varargin) == 3
                obj.k = varargin{1};
                obj.l = varargin{2};
                obj.m = varargin{3};
            elseif length(varargin) == 5
                obj.parseValues(varargin{4}, varargin{5})
            else
                error('Wrong number of arguments provided')
            end
        end
        
        function parseValues(obj, coordinates, values)
            for ind = 1:size(coordinates, 1)
                anchorInd = coordinates(ind, 3);
                currEnd = length(obj.mat{anchorInd});
                obj.mat{coordinates(ind, 3)}(currEnd + 1:currEnd +3) = [coordinates(ind, 1), coordinates(ind, 2), values(ind)];
            end 
        end
        
        function obj = subsasgn(obj, S, varargin)
            argin = varargin{1};
            handleError(obj, S)
            switch length(S.subs)
                case 3
                    obj.setElementsByIndexes(S.subs{1}, S.subs{2}, S.subs{3}, argin);
                otherwise
                    error('Not a valid indexing exception.');
            end
        end
        
        function setElementsByIndexes(obj, rows, cols, ancs, values)
            if rows == ':'
                rows = 1:obj.k;
            end
            if cols == ':'
                cols = 1:obj.l;
            end
            if ancs == ':'
                ancs = 1:obj.m;
            end
            
            if isa(values, 'double') && length(values) == 1
                for slice = ancs
                    obj.extendMatIfNeeded(slice);
                    sizeSlice = size(obj.mat{slice}, 2) / 3;
                    for row = rows
                        for col = cols
                            sizeSlice = obj.setForRowAndCol(slice, sizeSlice, row, col, values(1));
                        end
                    end
                end
            elseif ismatrix(values)
                if ~obj.checkIfMatDimMatching(values, length(rows), length(cols), length(ancs))
                    error('Matrix dimensions not matching')
                end
                % offset in matching dimensions
                offsetRow = rows(1) - 1;
                offsetCol = cols(1) - 1;
                for slice = ancs
                    sizeSlice = size(obj.mat{slice}, 2) / 3;
                    for row = rows
                        for col = cols
                            obj.setForRowAndCol(slice, sizeSlice, row, col, values(row - offsetRow, col - offsetCol))
                        end
                    end
                end
            elseif isa(values, 'SpTensor')
                
            end
            for slice = 1:obj.m
                obj.mat{slice}
            end
        end
        
        function matching = checkIfMatDimMatching(~, mat, rowsSize, colsSize, ancsSize)
            if rowsSize == size(mat, 1) && colsSize == size(mat, 2) && ancsSize == 1
                matching = 1;
            elseif rowsSize == size(mat, 1) && colsSize == 1 && ancsSize == size(mat, 2)
                matching = 1;
            elseif rowsSize == 1 && colsSize == size(mat, 1) && ancsSize == size(mat, 2)
                matching = 1;
            else
                matching = 0;
            end
        end 
       
        function sizeSlice = setForRowAndCol(obj, slice, sizeSlice, row, col, value)
            foundCoordinate = 0;
            for i = 1:sizeSlice
                foundRow = obj.mat{slice}(3 * i - 2);
                foundCol = obj.mat{slice}(3 * i - 1);
                if foundRow == row && foundCol == col
                    obj.mat{slice}(3 * i) = value;
                    foundCoordinate = 1;
                end
            end
            if ~foundCoordinate
                sizeSlice = sizeSlice + 1;
                obj.mat{slice}(sizeSlice * 3 - 2:sizeSlice * 3) = [row, col, value];
            end
        end
        
        function extendMatIfNeeded(obj, sliceIndex)
            if sliceIndex > obj.m
                obj.m = sliceIndex;
                obj.mat{sliceIndex} = [];
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
            
            if err
                baseException = MException(msgID,msg);
                throw(baseException)
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
        
        function outargs = subsref(obj, S)
            obj.handleError(S);
            if strcmp(S(1).type, '.')
                outargs = builtin('subsref', obj, S);
                return
            end
            
            switch length(S.subs)
                case 3
                    outargs = obj.getElementsBy3Indexes(S.subs{1}, S.subs{2}, S.subs{3});
                otherwise
                    error('Not a valid indexing exception.');
            end
        end
    end
end