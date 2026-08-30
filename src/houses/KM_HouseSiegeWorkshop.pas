unit KM_HouseSiegeWorkshop;
{$I KaM_Remake.inc}
interface
uses
  KM_CommonClasses, KM_Points, KM_Defaults,
  KM_Houses,
  KM_ResTypes;

type

  TKMHouseSiegeWorkshop = class(TKMHouseWFlagPoint)
  private
    fStoredMachines : array of TKMUnitType;
    fStoredCount : Word;
  protected

  public
    constructor Create(aUID: Integer; aHouseType: TKMHouseType; PosX, PosY: Integer; aOwner: TKMHandID; aBuildState: TKMHouseBuildState);
    constructor Load(LoadStream: TKMemoryStream); override;
    procedure Save(SaveStream: TKMemoryStream); override;

    procedure ConstructSiege(aUnitType : TKMunitType);

    function ObjToString(const aSeparator: string = '|'): string; override;
  end;


implementation
uses
  SysUtils, TypInfo,
  KM_ScriptingEvents,
  KM_HandsCollection,
  KM_UnitWarrior;


{ TKMHouseWoodcutters }
constructor TKMHouseSiegeWorkshop.Create(aUID: Integer; aHouseType: TKMHouseType; PosX, PosY: Integer; aOwner: TKMHandID; aBuildState: TKMHouseBuildState);
begin
  inherited;
end;


constructor TKMHouseSiegeWorkshop.Load(LoadStream: TKMemoryStream);
begin
  inherited;
end;

procedure TKMHouseSiegeWorkshop.Save(SaveStream: TKMemoryStream);
begin
  inherited;
end;

function TKMHouseSiegeWorkshop.ObjToString(const aSeparator: string = '|'): string;
begin
  Result := inherited ObjToString(aSeparator);
end;

procedure TKMHouseSiegeWorkshop.ConstructSiege(aUnitType: TKMUnitType);
var
  newWarrior: TKMUnitWarrior;
begin

  // Make new siege machine
  newWarrior := TKMUnitWarrior(gHands[Owner].TrainUnit(aUnitType, Self));
  newWarrior.Visible := False; //Make him invisible as he is inside the barracks
  newWarrior.SetActionGoIn(uaWalk, gdGoOutside, Self);
  if Assigned(newWarrior.OnUnitTrained) then
    newWarrior.OnUnitTrained(newWarrior);
end;

end.
