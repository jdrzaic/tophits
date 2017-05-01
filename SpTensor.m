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
            switch length(values)
                case 1
                    for slice = ancs
                        sizeSlice = size(obj.mat{slice}, 2) / 3;
                        for row = rows
                            for col = cols
                                sizeSlice = obj.setForRowAndCol(slice, sizeSlice, row, col, values);
                            end
                        end
                    end
                    obj.mat{1}
                    obj.mat{2}
                    obj.mat{3}
                otherwise
                    
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
    end
end