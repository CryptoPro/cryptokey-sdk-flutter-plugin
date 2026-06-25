import 'package:cpkey/api/crypto_pro_dss.dart';
import 'package:cpkey/api/signing_key.dart';

import 'api/auth.dart';
import 'api/cert.dart';
import 'api/docs.dart';
import 'api/policy.dart';
import 'api/sign.dart';
export 'src/generated/crypto_pro_dss_api.g.dart';

class CpKeyPlugin {
  static final CryptoProDss cryptoProDss = CryptoProDss();
  static final Auth auth = Auth();
  static final Cert cert = Cert();
  static final Docs docs = Docs();
  static final Policy policy = Policy();
  static final Sign sign = Sign();
  static final SigningKey signingKey = SigningKey();
}
