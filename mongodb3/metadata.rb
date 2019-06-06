name             'mongodb3'
<<<<<<< HEAD
maintainer       'UrbanLadder'
maintainer_email 'hello@urbanladder.com'
license          'Apache 2.0'
description      'Installs/Configures mongodb3'
long_description 'Installs/Configures mongodb3'
version          '2.0.0'

supports 'ubuntu', '= 12.04'
supports 'redhat', '= 6.6'
supports 'centos', '= 6.6'
supports 'oracle', '= 6.6'

depends 'apt'
depends 'yum'
depends 'runit'
=======
maintainer       'Sunggun Yu'
maintainer_email 'sunggun.dev@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures mongodb3'
long_description 'Installs/Configures mongodb3'
version          '5.3.0'

supports 'ubuntu', '>= 12.04'
supports 'debian', '= 7.8'
supports 'redhat', '= 6.6'
supports 'centos', '= 6.8'
supports 'centos', '= 7.2'
supports 'oracle', '= 6.6'
supports 'amazon'

depends 'apt'
depends 'yum'
depends 'user'
depends 'runit', '~> 1.7.0'
>>>>>>> 59123b7291922651a404c2a0fef43fc9bb9029c0
