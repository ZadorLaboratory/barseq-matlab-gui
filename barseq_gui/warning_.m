function warning_(options,varargin)
%Print a warning to the command window, a file and/or the String property of an object.
%The lastwarn state will be set if the warning isn't thrown with warning().
%The printed call trace omits this function, but the warning() call does not.
%
%The intention is to allow replacement of most warning(___) call with warning_(options,___). This
%does not apply to calls that query or set the warning state.
%
%options.con:         if true print warning to command window with warning()
%options.fid.boolean: if true print warning to file (options.fid.fid)
%options.obj.boolean: if true print warning to object (options.obj.obj)
%
%syntax:
%  warning_(options,msg)
%  warning_(options,msg,A1,...,An)
%  warning_(options,id,msg)
%  warning_(options,id,msg,A1,...,An)

if isempty(options),options=struct;end%Allow empty input to revert to default.
if ~isfield(options,'con'),options.con=false;end
if ~isfield(options,'fid'),options.fid.boolean=false;end
if ~isfield(options,'obj'),options.obj.boolean=false;end
if nargin==2 || ~isempty(strfind(varargin{1},'%'))%The id can't contain a percent symbol.
    %  warning_(options,msg,A1,...,An)
    [id,msg]=deal('',varargin{1});
    if nargin>3
        A1_An=varargin(2:end);
        msg=sprintf(msg,A1_An{:});
    end
else
    %  warning_(options,id,msg)
    %  warning_(options,id,msg,A1,...,An)
    [id,msg]=deal(varargin{1},varargin{2});
    if nargin>3
        A1_An=varargin(3:end);
        msg=sprintf(msg,A1_An{:});
    end
end

if options.con
    if ~isempty(id)
        warning(id,'%s',msg)
    else
        warning(msg)
    end
else
    if ~isempty(id)
        lastwarn(msg,id);
    else
        lastwarn(msg)
    end
end

if options.obj.boolean
    msg_=msg;while msg_(end)==10,msg_(end)=[];end%Crop trailing newline.
    if any(msg_==10)  % Parse to cellstr and prepend warning.
        msg_=regexp_outkeys(['Warning: ' msg_],char(10),'split'); %#ok<CHARTEN>
    else              % Only prepend warning.
        msg_=['Warning: ' msg_];
    end
    set(options.obj.obj,'String',msg_)
end

if options.fid.boolean
    skip_layers=2;%Remove this function and the get_trace function from the trace.
    trace=get_trace(skip_layers);
    fprintf(options.fid.fid,'Warning: %s\n%s',msg,trace);
end
end