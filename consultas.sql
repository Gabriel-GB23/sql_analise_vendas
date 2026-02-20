-- Projeto: Análise de Vendas com SQL
-- Autor: Gabriel Gomes
-- Objetivo: Explorar dados de vendas e responder perguntas de negócio
-- Banco: SQLite Online

-- 01 - Número total de clientes na base de dados:
select COUNT(id_cliente) from clientes;

-- 02 - Produtos totais vendidos em 2022:
select count(*) from itens_venda iv
join vendas v on v.id_venda = iv.venda_id
where strftime('%Y', v.data_venda) = '2022';

-- 03 - Categoria mais vendida em 2022:
select ca.nome_categoria, COUNT(iv.venda_id) Total_Vendas from categorias ca
join produtos p on p.categoria_id = ca.id_categoria
join itens_venda iv on iv.produto_id = p.id_produto
join vendas v on v.id_venda = iv.venda_id
where strftime('%Y', v.data_venda) = '2022'
group by ca.nome_categoria
order by Total_Vendas DESC
LIMIT 1;

-- 04 - Primeiro ano disponível na base de dados:
SELECT DISTINCT(strftime('%Y', data_venda)) as PrimeiroAno from vendas
order by strftime('%Y', data_venda)
limit 1;

-- 05 - Fornecedor com mais vendas no primeiro ano da base de dados, com quantidade vendida:
Select f.nome, count(iv.produto_id) Total_Vendas from fornecedores f
join produtos p on p.fornecedor_id = f.id_fornecedor
join itens_venda iv on iv.produto_id = p.id_produto
join vendas v on v.id_venda = iv.venda_id
where strftime('%Y', v.data_venda) = 
       (SELECT DISTINCT(strftime('%Y', data_venda)) from vendas
        order by strftime('%Y', data_venda)
        limit 1)
group by f.nome
order by Total_Vendas DESC
limit 1;

-- 06 - As duas categorias com mais vendas em todos os anos:
select ca.nome_categoria, COUNT(iv.venda_id) TotalVendasCategoria from categorias ca
join produtos p on p.categoria_id = ca.id_categoria
join itens_venda iv on iv.produto_id = p.id_produto
group by ca.nome_categoria
order by TotalVendasCategoria DESC
limit 2;

-- 07 - Tabela comparativa das vendas ao longo do tempo das duas categorias que mais venderam no total de todos os anos:
select "Ano/Mes",
SUM(CASE WHEN Nome_Categoria = 'Eletrônicos' THEN Qtd_Vendas Else 0 END) Vendas_Eletronicos,
SUM(CASE WHEN Nome_Categoria = 'Vestuário' THEN Qtd_Vendas Else 0 END) Vendas_Vestuario       -- Categorias definidas com base na consulta 6
from(
  select c.nome_categoria Nome_Categoria, strftime ('%Y/%m', v.data_venda) "Ano/Mes", COUNT(iv.venda_id) Qtd_Vendas
  from vendas v
  join itens_venda iv on iv.venda_id = v.id_venda
  join produtos p on p.id_produto = iv.produto_id
  join categorias c on c.id_categoria = p.categoria_id
  group by c.nome_categoria, "Ano/Mes"
)
group by "Ano/Mes"
order by "Ano/Mes";

-- 08 - Porcentagem de vendas por categoria em 2022:
SELECT Nome_Categoria, Total_Vendas, 
ROUND(100.0*Total_Vendas/
      (SELECT COUNT(*) from itens_venda iv
join vendas v on v.id_venda = iv.venda_id
where strftime('%Y', v.data_venda) = '2022'),2) || '%' AS Percentual
FROM(
  select ca.nome_categoria Nome_Categoria, COUNT(CASE WHEN strftime ('%Y', v.data_venda) = '2022' then iv.venda_id END) Total_Vendas from itens_venda iv
  join produtos p on p.id_produto = iv.produto_id
  join categorias ca on ca.id_categoria = p.categoria_id
  join vendas v on v.id_venda = iv.venda_id
  WHERE strftime ('%Y', v.data_venda) = '2022'
  group by ca.nome_categoria
  order by Total_Vendas DESC
  );
