# gm_scopes() reveals gmail scopes

    Code
      gm_scopes()
    Output
                                                          full 
                                    "https://mail.google.com/" 
                                                 gmail.compose 
               "https://www.googleapis.com/auth/gmail.compose" 
                                                gmail.readonly 
              "https://www.googleapis.com/auth/gmail.readonly" 
                                                  gmail.labels 
                "https://www.googleapis.com/auth/gmail.labels" 
                                                    gmail.send 
                  "https://www.googleapis.com/auth/gmail.send" 
                                                  gmail.insert 
                "https://www.googleapis.com/auth/gmail.insert" 
                                                  gmail.modify 
                "https://www.googleapis.com/auth/gmail.modify" 
                                                gmail.metadata 
              "https://www.googleapis.com/auth/gmail.metadata" 
                                          gmail.settings_basic 
        "https://www.googleapis.com/auth/gmail.settings.basic" 
                                        gmail.settings_sharing 
      "https://www.googleapis.com/auth/gmail.settings.sharing" 

# gm_scopes() substitutes full scope for legacy super-short form

    The use of extremely short scopes ("readonly") was deprecated in gmailr 2.0.0.
    i Please use the slightly longer form ("gmail.readonly") instead.

---

    The use of extremely short scopes ("readonly", "compose") was deprecated in gmailr 2.0.0.
    i Please use the slightly longer form ("gmail.readonly", "gmail.compose") instead.

