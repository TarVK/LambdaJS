module abstractData
import Lang;

str asStr(Identifier s) = "<s>";
data Const = Const(
	str name,
	int paramCount,
	Constructor const
);
