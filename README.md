<p align="center">
  <a href="https://github.com/swiftly-solution/swiftly">
    <img src="https://cdn.swiftlycs2.net/swiftly-logo.png" alt="SwiftlyLogo" width="80" height="80">
  </a>

  <h3 align="center">[Swiftly] AFKManager</h3>

</p>
    <h2>🛠️ Requirements</h2>
    <ul>
        <li><a href="https://github.com/swiftly-solution/admins/releases" target="_blank">Admins</a></li>
    </ul>
    <h2>⚙️ Configuration Guide</h2>
    <p>Time is in seconds..</p>
    <pre><code>
    {
        "prefix": "{red}[AFK Manager]{default}",
        "immunity": {
            "enable": true,
            "flags": "z"
        },
        "timer": {
            "interval": 1
        },
        "kick" : {
            "enable": true,
            "time": 120
        },
        "warn": {
            "enable": true,
            "time": [20, 40 , 60, 80, 100]
        },
        "slap": {
            "enable": true,
            "time": [ 50, 100 ],
            "damage": 0
        }
    }
    </code></pre>
