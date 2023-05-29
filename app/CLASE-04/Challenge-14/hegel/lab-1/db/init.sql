-- public."People" definition
-- Drop table
-- DROP TABLE public."People";

CREATE TABLE public."People" (
	id varchar NULL,
	"firstName" varchar NULL,
	"lastName" varchar NULL,
	"createdAt" date NULL DEFAULT now(),
	"updatedAt" date NULL DEFAULT now()
);

INSERT INTO public."People" ("id","firstName","lastName","createdAt","updatedAt") VALUES
	 ('1','MARIA','VELASCO','2022-11-12','2022-11-12'),
	 ('2','CAROLINA','LLANO','2022-11-12','2022-11-12');