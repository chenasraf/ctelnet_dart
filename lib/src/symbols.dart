class Symbols {
  // ASCII control characters

  /// IAC - Interpret as Command - 255
  static const int iac = 0xff;

  /// SE - Subnegotiation End - 240
  static const int se = 0xf0;

  /// NOP - No Operation - 241
  static const int nop = 0xf1;

  /// DM - Data Mark - 242
  static const int dm = 0xf2;

  /// BRK - Break - 243
  static const int brk = 0xf3;

  /// IP - Interrupt Process - 244
  static const int ip = 0xf4;

  /// AO - Abort Output - 245
  static const int ao = 0xf5;

  /// AYT - Are You There - 246
  static const int ayt = 0xf6;

  /// EC - Erase Character - 247
  static const int ec = 0xf7;

  /// EL - Erase Line - 248
  static const int el = 0xf8;

  /// GA - Go Ahead - 249
  static const int ga = 0xf9;

  /// SB - Subnegotiation Begin - 250
  static const int sb = 0xfa;

  /// WILL (option code) - 251
  static const int will = 0xfb;

  /// WONT (option code) - 252
  static const int wont = 0xfc;

  /// DO (option code) - 253
  static const int doo = 0xfd;

  /// DONT (option code) - 254
  static const int dont = 0xfe;
}

const symbolMap = {
  Symbols.iac: 'IAC',
  Symbols.se: 'SE',
  Symbols.nop: 'NOP',
  Symbols.dm: 'DM',
  Symbols.brk: 'BRK',
  Symbols.ip: 'IP',
  Symbols.ao: 'AO',
  Symbols.ayt: 'AYT',
  Symbols.ec: 'EC',
  Symbols.el: 'EL',
  Symbols.ga: 'GA',
  Symbols.sb: 'SB',
  Symbols.will: 'WILL',
  Symbols.wont: 'WONT',
  Symbols.doo: 'DO',
  Symbols.dont: 'DONT',
};

const reverseSymbolMap ={
  'IAC': Symbols.iac,
  'SE': Symbols.se,
  'NOP': Symbols.nop,
  'DM': Symbols.dm,
  'BRK': Symbols.brk,
  'IP': Symbols.ip,
  'AO': Symbols.ao,
  'AYT': Symbols.ayt,
  'EC': Symbols.ec,
  'EL': Symbols.el,
  'GA': Symbols.ga,
  'SB': Symbols.sb,
  'WILL': Symbols.will,
  'WONT': Symbols.wont,
  'DO': Symbols.doo,
  'DONT': Symbols.dont,
};
