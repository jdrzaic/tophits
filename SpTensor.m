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
                error('At least 3 arguments must be provided.');
            end
            obj.mat = cell(varargin{3}, 1);
            if length(varargin) == 3 || length(varargin) == 5
                obj.k = varargin{1};
                obj.l = varargin{2};
                obj.m = varargin{3};
                if length(varargin) == 5
                	obj.parseValues(varargin{4}, varargin{5});
                end            
            else
                error('Wrong number of arguments provided');
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
            handleError(obj, S);
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
            % set matrix size (slices are covered separately)
            if rows(length(rows)) > obj.k
                obj.k = rows(length(rows));
            end
            if cols(length(cols)) > obj.l
                obj.l = cols(length(cols));
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
            elseif isnumeric(values)
                if ~obj.checkIfMatDimMatching(values, length(rows), length(cols), length(ancs))
                    error('Matrix dimensions not matching.')
                end
                % offset in matching dimensions
                offsetRow = rows(1) - 1;
                offsetCol = cols(1) - 1;
                offsetSlice = ancs(1) - 1;
                for slice = ancs
                    obj.extendMatIfNeeded(slice);
                    sizeSlice = size(obj.mat{slice}, 2) / 3;
                    for row = rows
                        for col = cols
                            if length(ancs) == 1
                                value = values(row - offsetRow, col - offsetCol);
                            elseif length(cols) == 1
                                value = values(row - offsetRow, slice - offsetSlice);
                            else
                                value = values(col - offsetCol, slice - offsetSlice);
                            end
                            obj.setForRowAndCol(slice, sizeSlice, row, col, value);
                        end
                    end
                end
            elseif isa(values, 'SpTensor')
                if length(rows) ~= TensorOperations.size(values, 1) || length(cols) ~= TensorOperations.size(values, 2) || length(ancs) ~= TensorOperations.size(values, 3)
                    error('Tensor dimensions not matching.');
                end
                offsetRow = rows(1) - 1;
                offsetCol = cols(1) - 1;
                offsetAnc = ancs(1) - 1;
                for slice = ancs
                    obj.extendMatIfNeeded(slice);
                    sizeSlice = size(obj.mat{slice}, 2) / 3; % size of slice in obj
                    valueSizeSlice = size(values.mat{slice - offsetAnc}, 2) / 3; % size of slice in subtensor
                    for i = 1:valueSizeSlice
                        row = values.mat{slice - offsetAnc}(3 * i - 2);
                        col = values.mat{slice - offsetAnc}(3 * i - 1);
                        value = values.mat{slice - offsetAnc}(3 * i);
                        obj.setForRowAndCol(slice, sizeSlice, row + offsetRow, col + offsetCol, value);
                    end
                end
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
            if abs(value) < 10e-10
                return
            end
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
        
        function indexelements = getElementsByIndexes(obj, rows, cols, ancs)
            if rows == ':'
                rows = 1:obj.k;
            end
            if cols == ':'
                cols = 1:obj.l;
            end
            if ancs == ':'
                ancs = 1:obj.m;
            end
            if rows(length(rows)) > obj.k || cols(length(cols)) > obj.l || ancs(length(ancs)) > obj.m
                error('Unvalid index access');
            end
            type = 'tensor';
            if length(rows) == 1 || length(cols) == 1 || length(ancs) == 1
                type = 'matrix';
                if length(rows) == 1
                    newRowsNum = length(cols);
                    newColsNum = length(ancs);
                elseif length(cols) == 1
                    newRowsNum = length(rows);
                    newColsNum = length(ancs);
                else
                    newRowsNum = length(rows);
                    newColsNum = length(cols);
                end
            end
            offsetRow = rows(1) - 1;
            offsetCol = cols(1) - 1;
            offsetAnc = ancs(1) - 1;
            if strcmp(type, 'tensor')
                coords = [];
                values = [];
                offsetRow = rows(1) - 1;
                offsetCol = cols(1) - 1;
                offsetAnc = ancs(1) - 1;
                if rows(length(rows)) > obj.k || cols(length(cols)) > obj.l || ancs(length(ancs)) > obj.m
                    error('Unvalid index access');
                end
                for slice = ancs
                    sizeSlice = size(obj.mat{slice}, 2) / 3;
                    for i = 1:sizeSlice
                        foundRow = obj.mat{slice}(3 * i - 2);
                        foundCol = obj.mat{slice}(3 * i - 1);
                        if ismember(foundRow, rows) && ismember(foundCol, cols)
                            values(length(values) + 1) = obj.mat{slice}(3 * i);
                            coords(size(coords, 1) + 1, :) = [foundRow - offsetRow, foundCol - offsetCol, slice - offsetAnc];
                        end
                    end
                end
                % return sparse tensor
                indexelements = SpTensor(length(rows), length(cols), length(ancs), coords, values);
            else
                % return built-in sparse matrix
                % values to create sparse matrix
                rowsIndexes = [];
                colsIndexes = [];
                values = [];
                for slice = ancs
                    sizeSlice = size(obj.mat{slice}, 2) / 3;
                    for i = 1:sizeSlice
                        if ~ismember(obj.mat{slice}(3 * i - 2), rows) || ~ismember(obj.mat{slice}(3 * i - 1), cols)
                            continue
                        end
                        if length(rows) == 1
                            rowsIndexes(length(rowsIndexes) + 1) = obj.mat{slice}(3 * i - 1) - offsetCol;
                            colsIndexes(length(colsIndexes) + 1) = slice - offsetAnc;
                        elseif length(cols) == 1
                            rowsIndexes(length(rowsIndexes) + 1) = obj.mat{slice}(3 * i - 2) - offsetRow;
                            colsIndexes(length(colsIndexes) + 1) = slice - offsetAnc;
                        else
                            rowsIndexes(length(rowsIndexes) + 1) = obj.mat{slice}(3 * i - 2) - offsetRow;
                            colsIndexes(length(colsIndexes) + 1) = obj.mat{slice}(3 * i - 1) - offsetCol;
                        end
                        values(length(values) + 1) = obj.mat{slice}(3 * i); 
                    end
                end
                indexelements = sparse(rowsIndexes, colsIndexes, values, newRowsNum, newColsNum);
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
                    outargs = obj.getElementsByIndexes(S.subs{1}, S.subs{2}, S.subs{3});
                otherwise
                    error('Not a valid indexing exception.');
            end
        end
        
    end
end