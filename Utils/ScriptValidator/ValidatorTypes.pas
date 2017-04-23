unit ValidatorTypes;

interface
type
  TCLIParamRecord = packed record
    ScriptFile: string;
    Help,
    Campaign,
    Version,
    Verbose:    Boolean;
  end;

implementation
end.
