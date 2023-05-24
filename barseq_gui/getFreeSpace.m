function free = getFreeSpace(path)

    if nargin < 1 || isempty(path)
        path= '.';
    end

    free = java.io.File(path).getFreeSpace();

end