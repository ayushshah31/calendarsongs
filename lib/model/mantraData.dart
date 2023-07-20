class MantraModel{
  late String _benefits,  _introSoundFile,  _introLink,  _mantraEnglish,  _mantraHindi,  _mantraSoundFile, _mantraLink, _procedure, _noOfRep;
  late int _tithi;

  MantraModel();

  get benefits => _benefits;

  set benefits(value) {
    _benefits = value;
  }

  get introSoundFile => _introSoundFile;

  set introSoundFile(value) {
    _introSoundFile = value;
  }

  get introLink => _introLink;

  set introLink(value) {
    _introLink = value;
  }

  get mantraEnglish => _mantraEnglish;

  set mantraEnglish(value) {
    _mantraEnglish = value;
  }

  get mantraHindi => _mantraHindi;

  set mantraHindi(value) {
    _mantraHindi = value;
  }

  get mantraSoundFile => _mantraSoundFile;

  set mantraSoundFile(value) {
    _mantraSoundFile = value;
  }

  get mantraLink => _mantraLink;

  set mantraLink(value) {
    _mantraLink = value;
  }
  get procedure => _procedure;

  set procedure(value) {
    _procedure = value;
  }
  get noOfRep => _noOfRep;

  set noOfRep(value) {
    _noOfRep = value;
  }
  get tithi => _tithi;

  set tithi(value) {
    _tithi = value;
  }
}