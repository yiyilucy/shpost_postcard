class WechatInterface
  HttpType = 'post'
  ParamsRequire = '1'
  SecurityLevel = '0'
  # ModeInWithSign = 0x1
  # ModeInWithEncrypt = 0x2
  # ModeOutWithSign = 0x4
  # ModeOutWithEncrypt = 0x8
  # ModeOutZip = 0x20

  # AlgEncryptAES128=0x1
  # AlgEncryptAES256=0x2

  # AlgSignMD5WithRSA=0x100
  # AlgSignSHA256WithRSA=0x200
  HttpUri = 'https://kf.shpost.com.cn/shpost/public/rpc/shpostwx/oauth2helper/openid'
  # URI = 'https://kf.shpost.com.cn/shpost/public/rpc/shpostwx/oauth2helper/userid'
  # PriPassPhrase = ExamConfig.config["wx_interface"]["pri_key_pass"]
  # PrikeyPath = ExamConfig.config["wx_interface"]["pri_key_path"]

  def self.http_send http_type, uri, params
    send_url = URI.parse(HttpUri)
    response = HTTPClient.send http_type, send_url, params
    response.body
  end

  # def self.wechat_post(uri,params)
  #   HTTPClient
  #   url = URI.parse(uri)
  #   res = Net::HTTP.post_form(url, params)
  #   return res
  # end

  def self.callWechatInterface state, code
    # puts "state:" + state.to_s
    # puts "code:" + code.to_s
    # uri = "http://10.126.16.168/shpost/public/rpc/shpostwxc/oauth2helper/userid"
    # uri = "http://172.16.89.201/shpost/public/rpc/shpostwxc/oauth2helper/userid"
    # uri = ExamConfig.config["wx_interface"]["uri"]
    response = http_send HttpType, HttpUri, getWechatParams(state, code)

  end

  def self.getWechatParams state, code
    params = {}
    params["weixinPublicId"] = state
    # params["corpId"] = state
    params["oauth2_code"] = code
    params["require"] = ParamsRequire
    # params["systemId"] = ExamConfig.config["wx_interface"]["systemId"]
    params["securityLevel"] = SecurityLevel
    return params

  end

  # # def parseWxResponse res
  #   if res.code.eql? '200'
  #     resbody = JSON.parse res.body
  #     code = resbody["code"]
  #     data = resbody["data"]
  #     key = resbody["key"]
  #     message = resbody["message"]

  #     puts "code:" + code.to_s
  #     puts "data:" + data.to_s
  #     puts "key:" + key.to_s
  #     if code == "0"
  #       full_key = decryptKey key
  #       aes_key = full_key[0..15]
  #       aes_vi = full_key[16..31]
  #       deData = decryptData data, aes_key, aes_vi
  #       return [0,deData]
  #     else
  #       puts "message:" + message.to_s
  #       return [1,message.to_s]
  #     end
  #   else
  #     return [1,"HTTP CODE IS NOT 200"]
  #   end

  # end

  # def getSign data
  #   e = Encrypt.new
  #   encrypt = e.md5_with_rsa_sign(data, RSAkeyPath, PriPassPhrase)
  #   return Base64.strict_encode64(encrypt)
  # end

  # def decryptKey data
  #   e = Encrypt.new
  #   decryptKey = e.rsa_private_decrypt(Base64.strict_decode64(data), PrikeyPath, PriPassPhrase)
  #   puts "decryptKey:" + decryptKey
  #   return decryptKey
  # end

  # def decryptData data, aes_key, aes_vi
  #   e = Encrypt.new
  #   decryptData = e.aes_decrypt_cbc_pkcs7padding Base64.strict_decode64(data), aes_key, aes_vi
  #   puts "decryptData:" + decryptData
  #   return decryptData
  # end

end