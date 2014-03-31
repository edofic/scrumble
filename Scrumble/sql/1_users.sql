USE Scrumble;

INSERT INTO user(username, first_name, last_name, email, role) VALUES ("admin", "Ad", "Min", "admin@scrumble.lukazakrajsek.com", "Administrator");
INSERT INTO user(username, first_name, last_name, email, role) VALUES ("john", "John", "Doe", "john.doe@scrumble.lukazakrajsek.com", "RegularUser");
INSERT INTO user(username, first_name, last_name, email, role) VALUES ("jane", "Jane", "Doe", "jane.doe@scrumble.lukazakrajsek.com", "RegularUser");

INSERT INTO user_auth(username, password) VALUES("admin", "sha256|12|iyQpS80aWh3TAChjLMUTuQ==|W9n291ZTSAjoc/DJoFYA7uVSITSN1ZDcb6RxWI5RyDU="); -- PassWord!
INSERT INTO user_auth(username, password) VALUES("john", "sha256|12|W7vrE2JQ+lW+mY/kprFozA==|p1TaUyi65FKBKeD3O/gx1V5Gy1SqTAmPZmfhmghMVeM=");  -- GreenIsNotBlue
INSERT INTO user_auth(username, password) VALUES("jane", "sha256|12|38FVTmV5QEkQhok2FLJONw==|nQBgRwVOhQWcGe3jnYhtLp28YMIM9GJaCvdihxVmbHs=");  -- Silence!IKillYou
